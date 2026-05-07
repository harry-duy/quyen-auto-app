package com.quyenauto.chat.entity;

import com.quyenauto.common.entity.BaseEntity;
import com.quyenauto.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "chat_rooms",
        uniqueConstraints = @UniqueConstraint(columnNames = {"customer_id", "staff_id"}))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatRoom extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "staff_id")
    private User staff;
}
