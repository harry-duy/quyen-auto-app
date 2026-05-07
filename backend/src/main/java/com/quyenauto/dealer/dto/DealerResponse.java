package com.quyenauto.dealer.dto;

import com.quyenauto.dealer.entity.Dealer;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class DealerResponse {
    private Long id;
    private String name;
    private String address;
    private String province;
    private String phone;
    private Double lat;
    private Double lng;
    private Boolean isActive;

    public static DealerResponse from(Dealer d) {
        return DealerResponse.builder()
                .id(d.getId())
                .name(d.getName())
                .address(d.getAddress())
                .province(d.getProvince())
                .phone(d.getPhone())
                .lat(d.getLat())
                .lng(d.getLng())
                .isActive(d.getIsActive())
                .build();
    }
}
