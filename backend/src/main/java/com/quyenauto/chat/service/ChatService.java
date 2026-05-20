package com.quyenauto.chat.service;

import com.quyenauto.chat.dto.ChatMessageResponse;
import com.quyenauto.chat.dto.ChatRoomResponse;
import com.quyenauto.chat.dto.SendMessageRequest;
import com.quyenauto.chat.dto.StartChatRequest;
import com.quyenauto.chat.entity.ChatMessage;
import com.quyenauto.chat.entity.ChatRoom;
import com.quyenauto.chat.repository.ChatMessageRepository;
import com.quyenauto.chat.repository.ChatRoomRepository;
import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.notification.service.NotificationService;
import com.quyenauto.user.entity.User;
import com.quyenauto.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ChatService {

    private final ChatRoomRepository roomRepository;
    private final ChatMessageRepository messageRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final SimpMessagingTemplate messagingTemplate;

    public List<ChatRoomResponse> getRooms(Long userId) {
        List<ChatRoom> rooms = roomRepository.findByUserId(userId);
        return rooms.stream().map(room -> toChatRoomResponse(room, userId)).toList();
    }

    public Page<ChatMessageResponse> getMessages(Long roomId, Pageable pageable) {
        return messageRepository.findByRoomIdOrderByCreatedAtDesc(roomId, pageable)
                .map(ChatMessageResponse::from);
    }

    @Transactional
    public ChatMessageResponse sendMessage(Long senderId, SendMessageRequest request) {
        ChatRoom room = roomRepository.findById(request.getRoomId())
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy phòng chat"));

        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));

        ChatMessage message = ChatMessage.builder()
                .room(room)
                .sender(sender)
                .content(request.getContent())
                .type(ChatMessage.MessageType.valueOf(request.getType().toUpperCase()))
                .isRead(false)
                .build();

        return ChatMessageResponse.from(messageRepository.save(message));
    }

    /**
     * Khách hàng mở chat mới (chưa cần biết staff nào).
     * Tạo phòng với staff = null, gửi thông báo đến tất cả STAFF/MANAGER.
     */
    @Transactional
    public ChatRoomResponse startChat(Long customerId, StartChatRequest request) {
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy khách hàng"));

        // Nếu đã có phòng chờ (staff = null) của customer này → dùng lại
        ChatRoom room = roomRepository
                .findWaitingRoomByCustomerId(customerId)
                .orElseGet(() -> roomRepository.save(
                        ChatRoom.builder()
                                .customer(customer)
                                .orderCode(request.getOrderCode())
                                .build()));

        // Gửi tin nhắn đầu tiên nếu có
        if (request.getFirstMessage() != null && !request.getFirstMessage().isBlank()) {
            ChatMessage firstMsg = ChatMessage.builder()
                    .room(room)
                    .sender(customer)
                    .content(request.getFirstMessage())
                    .type(ChatMessage.MessageType.TEXT)
                    .isRead(false)
                    .build();
            messageRepository.save(firstMsg);
        }

        // Thông báo đến toàn bộ STAFF/MANAGER
        String orderInfo = request.getOrderCode() != null ? " — Đơn: " + request.getOrderCode() : "";
        notificationService.notifyAllStaff(
                "Khách hàng cần hỗ trợ",
                customer.getFullName() + " cần tư vấn" + orderInfo,
                "CHAT_REQUEST",
                room.getId().toString()
        );

        // Push WS event đến topic chung để staff-list tự refresh
        messagingTemplate.convertAndSend("/topic/chat.new-room",
                toChatRoomResponse(room, customerId));

        return toChatRoomResponse(room, customerId);
    }

    /**
     * Nhân viên tiếp nhận phòng chat đang chờ.
     * Sau khi claim, broadcast "/topic/chat.claimed.{roomId}" để các staff khác bỏ badge.
     */
    @Transactional
    public ChatRoomResponse claimRoom(Long roomId, Long staffId) {
        ChatRoom room = roomRepository.findById(roomId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy phòng chat"));

        if (room.getStaff() != null) {
            throw new BusinessException(HttpStatus.CONFLICT,
                    "Phòng chat đã được tiếp nhận bởi " + room.getStaff().getFullName());
        }

        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy nhân viên"));

        room.setStaff(staff);
        roomRepository.save(room);

        // Gửi tin nhắn hệ thống
        ChatMessage sysMsg = ChatMessage.builder()
                .room(room)
                .sender(staff)
                .content(staff.getFullName() + " đã tiếp nhận cuộc trò chuyện")
                .type(ChatMessage.MessageType.TEXT)
                .isRead(false)
                .build();
        messageRepository.save(sysMsg);

        // Thông báo cho khách hàng
        notificationService.createNotification(
                room.getCustomer().getId(),
                "Hỗ trợ đã tiếp nhận",
                staff.getFullName() + " đang hỗ trợ bạn",
                "CHAT_CLAIMED",
                room.getId().toString()
        );

        // Push WS event để tất cả staff refresh danh sách
        messagingTemplate.convertAndSend("/topic/chat.claimed." + roomId,
                toChatRoomResponse(room, staffId));

        return toChatRoomResponse(room, staffId);
    }

    @Transactional
    public ChatRoomResponse getOrCreateRoom(Long customerId, Long staffId) {
        ChatRoom room = roomRepository.findByCustomerIdAndStaffId(customerId, staffId)
                .orElseGet(() -> {
                    User customer = userRepository.findById(customerId)
                            .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy khách hàng"));
                    User staff = userRepository.findById(staffId)
                            .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy nhân viên"));
                    return roomRepository.save(ChatRoom.builder().customer(customer).staff(staff).build());
                });
        return toChatRoomResponse(room, customerId);
    }

    @Transactional
    public void markAsRead(Long roomId, Long userId) {
        messageRepository.markAllRead(roomId, userId);
    }

    private ChatRoomResponse toChatRoomResponse(ChatRoom room, Long currentUserId) {
        ChatMessage latest = messageRepository.findFirstByRoomIdOrderByCreatedAtDesc(room.getId());
        long unread = messageRepository.countUnread(room.getId(), currentUserId);

        return ChatRoomResponse.builder()
                .id(room.getId())
                .customerId(room.getCustomer().getId())
                .customerName(room.getCustomer().getFullName())
                .customerAvatar(room.getCustomer().getAvatarUrl())
                .staffId(room.getStaff() != null ? room.getStaff().getId() : null)
                .staffName(room.getStaff() != null ? room.getStaff().getFullName() : null)
                .staffAvatar(room.getStaff() != null ? room.getStaff().getAvatarUrl() : null)
                .orderCode(room.getOrderCode())
                .isWaiting(room.getStaff() == null)
                .lastMessage(latest != null ? latest.getContent() : null)
                .lastMessageAt(latest != null ? latest.getCreatedAt() : room.getCreatedAt())
                .unreadCount(unread)
                .build();
    }
}
