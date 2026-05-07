package com.quyenauto.chat.controller;

import com.quyenauto.chat.dto.ChatMessageResponse;
import com.quyenauto.chat.dto.ChatRoomResponse;
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
        return ResponseEntity.ok(ApiResponse.ok(chatService.getRooms(userId)));
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
}
