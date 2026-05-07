package com.quyenauto.chat.repository;

import com.quyenauto.chat.entity.ChatMessage;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    Page<ChatMessage> findByRoomIdOrderByCreatedAtDesc(Long roomId, Pageable pageable);

    @Query("SELECT COUNT(m) FROM ChatMessage m WHERE m.room.id = :roomId AND m.isRead = false AND m.sender.id <> :userId")
    long countUnread(Long roomId, Long userId);

    @Modifying
    @Query("UPDATE ChatMessage m SET m.isRead = true WHERE m.room.id = :roomId AND m.sender.id <> :userId AND m.isRead = false")
    void markAllRead(Long roomId, Long userId);

    ChatMessage findFirstByRoomIdOrderByCreatedAtDesc(Long roomId);
}
