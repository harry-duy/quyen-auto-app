package com.quyenauto.warranty.service;

import com.quyenauto.notification.service.NotificationService;
import com.quyenauto.warranty.entity.Vehicle;
import com.quyenauto.warranty.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class WarrantyExpiryScheduler {

    private final VehicleRepository vehicleRepository;
    private final NotificationService notificationService;

    // Runs every day at 8:00 AM
    @Scheduled(cron = "0 0 8 * * *")
    public void checkWarrantyExpiry() {
        LocalDate today = LocalDate.now();
        notifyForDate(today.plusDays(30), "Bảo hành sắp hết hạn", "Xe %s còn 30 ngày bảo hành (hết hạn %s)");
        notifyForDate(today.plusDays(7), "Bảo hành sắp hết hạn", "Xe %s còn 7 ngày bảo hành (hết hạn %s)");
        notifyForDate(today.plusDays(1), "Bảo hành hết hạn ngày mai", "Xe %s hết hạn bảo hành vào ngày mai (%s)");
        notifyForDate(today, "Bảo hành đã hết hạn", "Xe %s đã hết hạn bảo hành hôm nay (%s)");
    }

    private void notifyForDate(LocalDate targetDate, String title, String bodyTemplate) {
        List<Vehicle> vehicles = vehicleRepository.findByWarrantyExpiryDate(targetDate);
        for (Vehicle v : vehicles) {
            String body = String.format(bodyTemplate, v.getPlateNumber(), targetDate);
            try {
                notificationService.createNotification(
                        v.getOwner().getId(),
                        title,
                        body,
                        "WARRANTY_EXPIRY",
                        v.getId().toString()
                );
            } catch (Exception e) {
                log.warn("Failed to notify owner {} for vehicle {}: {}", v.getOwner().getId(), v.getId(), e.getMessage());
            }
        }
        if (!vehicles.isEmpty()) {
            log.info("Warranty expiry check for {}: notified {} vehicle owners", targetDate, vehicles.size());
        }
    }
}
