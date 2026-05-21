package com.quyenauto.chat.websocket;

import com.quyenauto.chat.dto.ChatMessageResponse;
import com.quyenauto.chat.dto.SendMessageRequest;
import com.quyenauto.chat.dto.TypingMessage;
import com.quyenauto.chat.service.ChatService;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.security.Principal;

@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {

    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/chat.send")
    public void sendMessage(@Payload SendMessageRequest request, Principal principal) {
        Long senderId = Long.parseLong(principal.getName());
        ChatMessageResponse message = chatService.sendMessage(senderId, request);

        messagingTemplate.convertAndSend("/topic/chat.room." + request.getRoomId(), message);
    }

    @MessageMapping("/chat.read")
    public void markRead(@Payload Long roomId, Principal principal) {
        Long userId = Long.parseLong(principal.getName());
        chatService.markAsRead(roomId, userId);
        messagingTemplate.convertAndSend("/topic/chat.room." + roomId,
                Map.of("event", "READ", "userId", userId));
    }

    @MessageMapping("/chat.typing")
    public void typing(@Payload TypingMessage msg, Principal principal) {
        messagingTemplate.convertAndSend(
                "/topic/chat.typing." + msg.getRoomId(),
                Map.of("userId", Long.parseLong(principal.getName()), "typing", msg.isTyping()));
    }
}
