package com.quyenauto.chat.service;

import com.quyenauto.chat.dto.ChatMessageResponse;
import com.quyenauto.chat.dto.ChatRoomResponse;
import com.quyenauto.chat.dto.SendMessageRequest;
import com.quyenauto.chat.entity.ChatMessage;
import com.quyenauto.chat.entity.ChatRoom;
import com.quyenauto.chat.repository.ChatMessageRepository;
import com.quyenauto.chat.repository.ChatRoomRepository;
import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.user.entity.User;
import com.quyenauto.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatRoomRepository roomRepository;
    private final ChatMessageRepository messageRepository;
    private final UserRepository userRepository;

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
                .lastMessage(latest != null ? latest.getContent() : null)
                .lastMessageAt(latest != null ? latest.getCreatedAt() : room.getCreatedAt())
                .unreadCount(unread)
                .build();
    }
}
