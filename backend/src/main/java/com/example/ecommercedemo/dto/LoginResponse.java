package com.example.ecommercedemo.dto;

public class LoginResponse {

    private Long userId;
    private UserDto user;
    private String message;

    public LoginResponse() {
    }

    public LoginResponse(Long userId, UserDto user, String message) {
        this.userId = userId;
        this.user = user;
        this.message = message;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public UserDto getUser() {
        return user;
    }

    public void setUser(UserDto user) {
        this.user = user;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
