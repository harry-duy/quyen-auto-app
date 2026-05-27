package com.quyenauto.chat.controller;

import com.quyenauto.chat.dto.ChatMessageResponse;
import com.quyenauto.chat.dto.ChatRoomResponse;
import com.quyenauto.chat.dto.SendMessageRequest;
import com.quyenauto.chat.dto.StartChatRequest;
import com.quyenauto.chat.service.ChatService;
import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.common.dto.PageResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
@Tag(name = "Chat", description = "Tin nhắn & phòng chat")
public class ChatController {

    private final ChatService chatService;

    @GetMapping("/rooms")
    @Operation(summary = "Danh sách phòng chat")
    public ResponseEntity<ApiResponse<List<ChatRoomResponse>>> getRooms(Authentication auth) {
        Long userId = Long.parseLong(auth.getName());
        boolean isStaff = auth.getAuthorities().stream()
                .anyMatch(a -> !a.getAuthority().equals("ROLE_CUSTOMER"));
        return ResponseEntity.ok(ApiResponse.ok(chatService.getRooms(userId, isStaff)));
    }

    @GetMapping("/rooms/{roomId}/messages")
    @Operation(summary = "Tin nhắn trong phòng chat (phân trang)")
    public ResponseEntity<ApiResponse<PageResponse<ChatMessageResponse>>> getMessages(
            @PathVariable Long roomId, @PageableDefault(size = 50) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(chatService.getMessages(roomId, pageable))));
    }

    @PostMapping("/rooms/{roomId}/read")
    @Operation(summary = "Đánh dấu đã đọc")
    public ResponseEntity<ApiResponse<Void>> markAsRead(
            @PathVariable Long roomId, Authentication auth) {
        Long userId = Long.parseLong(auth.getName());
        chatService.markAsRead(roomId, userId);
        return ResponseEntity.ok(ApiResponse.noContent());
    }

    @PostMapping("/rooms/init")
    @Operation(summary = "Tạo hoặc lấy phòng chat giữa khách hàng và nhân viên")
    public ResponseEntity<ApiResponse<ChatRoomResponse>> getOrCreateRoom(
            @RequestParam Long customerId, @RequestParam Long staffId) {
        return ResponseEntity.ok(ApiResponse.ok(chatService.getOrCreateRoom(customerId, staffId)));
    }

    @PostMapping("/rooms/start")
    @Operation(summary = "Khách hàng mở chat mới (gửi tới tất cả staff)")
    public ResponseEntity<ApiResponse<ChatRoomResponse>> startChat(
            @RequestBody StartChatRequest request, Authentication auth) {
        Long customerId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(chatService.startChat(customerId, request)));
    }

    @PatchMapping("/rooms/{roomId}/claim")
    @Operation(summary = "Nhân viên tiếp nhận phòng chat đang chờ")
    public ResponseEntity<ApiResponse<ChatRoomResponse>> claimRoom(
            @PathVariable Long roomId, Authentication auth) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(chatService.claimRoom(roomId, staffId)));
    }

    @PostMapping("/rooms/{roomId}/messages")
    @Operation(summary = "Gửi tin nhắn")
    public ResponseEntity<ApiResponse<ChatMessageResponse>> sendMessage(
            @PathVariable Long roomId, @RequestBody SendMessageRequest request, Authentication auth) {
        Long senderId = Long.parseLong(auth.getName());
        request.setRoomId(roomId);
        return ResponseEntity.ok(ApiResponse.ok(chatService.sendMessage(senderId, request)));
    }
}
