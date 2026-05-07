package com.quyenauto.dealer.repository;

import com.quyenauto.dealer.entity.Dealer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DealerRepository extends JpaRepository<Dealer, Long> {

    List<Dealer> findByIsActiveTrueOrderByProvinceAsc();

    List<Dealer> findByProvinceAndIsActiveTrue(String province);
}
