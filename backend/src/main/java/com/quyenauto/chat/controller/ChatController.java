package com.quyenauto.chat.controller;

import com.quyenauto.chat.dto.ChatMessageResponse;
import com.quyenauto.chat.dto.ChatRoomResponse;
import com.quyenauto.chat.service.ChatService;
import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.common.dto.PageResponse;
import com.quyenauto.common.exception.BusinessException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
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
    @Operation(summary = "Tin nhắn trong phòng chat (phân trang) — chỉ thành viên phòng mới xem được")
    public ResponseEntity<ApiResponse<PageResponse<ChatMessageResponse>>> getMessages(
            @PathVariable Long roomId,
            @PageableDefault(size = 50) Pageable pageable,
            Authentication auth) {
        Long userId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(
                ApiResponse.ok(PageResponse.of(chatService.getMessages(roomId, userId, pageable))));
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
    @Operation(summary = "Tạo hoặc lấy phòng chat. Customer: customerId tự lấy từ JWT, staffId tuỳ chọn. Staff/Admin: truyền customerId bắt buộc.")
    public ResponseEntity<ApiResponse<ChatRoomResponse>> getOrCreateRoom(
            @RequestParam(required = false) Long customerId,
            @RequestParam(required = false) Long staffId,
            Authentication auth) {
        Long callerId = Long.parseLong(auth.getName());
        boolean isCustomer = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_CUSTOMER"));

        if (isCustomer) {
            // Customer chỉ được tạo phòng cho chính mình
            customerId = callerId;
        } else {
            // Staff/Admin cần truyền customerId
            if (customerId == null) {
                throw new BusinessException(HttpStatus.BAD_REQUEST,
                        "Staff/Admin cần truyền customerId để tạo phòng chat");
            }
        }
        return ResponseEntity.ok(ApiResponse.ok(chatService.getOrCreateRoom(customerId, staffId)));
    }
}
