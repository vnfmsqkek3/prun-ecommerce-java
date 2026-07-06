package com.example.ecommercedemo.dto;

import com.example.ecommercedemo.entity.User;

import java.time.LocalDateTime;

public class UserDto {

    private Long id;
    private String email;
    private String name;
    private String phoneNumber;
    private LocalDateTime createdAt;

    public UserDto() {
    }

    public static UserDto from(User user) {
        UserDto dto = new UserDto();
        dto.id = user.getId();
        dto.email = user.getEmail();
        dto.name = user.getName();
        dto.phoneNumber = user.getPhoneNumber();
        dto.createdAt = user.getCreatedAt();
        return dto;
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getName() {
        return name;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
