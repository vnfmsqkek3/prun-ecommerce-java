package com.example.ecommercedemo.controller;

import com.example.ecommercedemo.dto.*;
import com.example.ecommercedemo.service.UserService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/signup")
    public ResponseEntity<UserDto> signup(@Valid @RequestBody UserSignupDto dto) {
        UserDto user = userService.signup(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody UserLoginDto dto, HttpSession session) {
        LoginResponse response = userService.login(dto);
        // Persisted to ElastiCache (Redis) so any autoscaled backend instance sees the session
        session.setAttribute("userId", response.getUserId());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/me")
    public ResponseEntity<UserDto> selectUser(@RequestHeader("X-User-Id") Long userId) {
        UserDto user = userService.selectUser(userId);
        return ResponseEntity.ok(user);
    }

    @PutMapping("/me")
    public ResponseEntity<UserDto> updateUser(
            @RequestHeader("X-User-Id") Long userId,
            @Valid @RequestBody UserUpdateDto dto) {
        UserDto user = userService.updateUser(userId, dto);
        return ResponseEntity.ok(user);
    }

    @PutMapping("/me/password")
    public ResponseEntity<Void> changePassword(
            @RequestHeader("X-User-Id") Long userId,
            @Valid @RequestBody PasswordChangeDto dto) {
        userService.changePassword(userId, dto);
        return ResponseEntity.noContent().build();
    }
}
