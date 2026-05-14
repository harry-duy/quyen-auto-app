package com.quyenauto.dealer.service;

import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.dealer.dto.CreateDealerRequest;
import com.quyenauto.dealer.dto.DealerResponse;
import com.quyenauto.dealer.entity.Dealer;
import com.quyenauto.dealer.repository.DealerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DealerService {

    private final DealerRepository dealerRepository;

    public List<DealerResponse> getAll(String province) {
        List<Dealer> dealers;
        if (province != null && !province.isBlank()) {
            dealers = dealerRepository.findByProvinceAndIsActiveTrue(province);
        } else {
            dealers = dealerRepository.findByIsActiveTrueOrderByProvinceAsc();
        }
        return dealers.stream().map(DealerResponse::from).toList();
    }

    public DealerResponse getById(Long id) {
        Dealer dealer = dealerRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy đại lý"));
        return DealerResponse.from(dealer);
    }

    @Transactional
    public DealerResponse create(CreateDealerRequest request) {
        Dealer dealer = Dealer.builder()
                .name(request.getName())
                .address(request.getAddress())
                .province(request.getProvince())
                .phone(request.getPhone())
                .lat(request.getLat())
                .lng(request.getLng())
                .isActive(true)
                .build();
        return DealerResponse.from(dealerRepository.save(dealer));
    }

    public List<DealerResponse> getNearest(double lat, double lng, int limit) {
        return dealerRepository.findByIsActiveTrueOrderByProvinceAsc().stream()
                .sorted(Comparator.comparingDouble(d -> haversineKm(lat, lng, d.getLat(), d.getLng())))
                .limit(limit)
                .map(DealerResponse::from)
                .toList();
    }

    private double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        final double R = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    @Transactional
    public DealerResponse update(Long id, CreateDealerRequest request) {
        Dealer dealer = dealerRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy đại lý"));

        dealer.setName(request.getName());
        dealer.setAddress(request.getAddress());
        dealer.setProvince(request.getProvince());
        dealer.setPhone(request.getPhone());
        dealer.setLat(request.getLat());
        dealer.setLng(request.getLng());

        return DealerResponse.from(dealerRepository.save(dealer));
    }
}
