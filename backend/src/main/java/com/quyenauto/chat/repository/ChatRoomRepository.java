package com.quyenauto.chat.repository;

import com.quyenauto.chat.entity.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {

    Optional<ChatRoom> findByCustomerIdAndStaffId(Long customerId, Long staffId);

    @Query("SELECT r FROM ChatRoom r WHERE r.customer.id = :userId OR r.staff.id = :userId ORDER BY r.updatedAt DESC")
    List<ChatRoom> findByUserId(Long userId);
}
