package com.quyenauto.warranty.repository;

import com.quyenauto.warranty.entity.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface VehicleRepository extends JpaRepository<Vehicle, Long> {

    List<Vehicle> findByOwnerId(Long ownerId);

    Optional<Vehicle> findByChassisNumber(String chassisNumber);

    boolean existsByChassisNumber(String chassisNumber);
}
