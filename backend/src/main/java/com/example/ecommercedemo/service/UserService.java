package com.example.ecommercedemo.service;

import com.example.ecommercedemo.dto.*;
import com.example.ecommercedemo.entity.User;
import com.example.ecommercedemo.exception.BusinessException;
import com.example.ecommercedemo.exception.ErrorCode;
import com.example.ecommercedemo.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class UserService {

    private static final Logger log = LoggerFactory.getLogger(UserService.class);
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public UserDto signup(UserSignupDto dto) {
        log.info("회원가입 시작 - email: {}", dto.getEmail());

        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new BusinessException(ErrorCode.DUPLICATE_EMAIL);
        }

        User user = User.create(
                dto.getEmail(),
                dto.getPassword(),
                dto.getName(),
                dto.getPhoneNumber()
        );

        User savedUser = userRepository.save(user);
        log.info("회원가입 완료 - id: {}, email: {}", savedUser.getId(), savedUser.getEmail());

        return UserDto.from(savedUser);
    }

    public LoginResponse login(UserLoginDto dto) {
        log.info("로그인 시도 - email: {}", dto.getEmail());

        User user = userRepository.findByEmail(dto.getEmail())
                .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_CREDENTIALS));

        if (!user.getPassword().equals(dto.getPassword())) {
            throw new BusinessException(ErrorCode.INVALID_CREDENTIALS);
        }

        log.info("로그인 성공 - userId: {}", user.getId());
        return new LoginResponse(user.getId(), UserDto.from(user), "로그인 성공");
    }

    public UserDto selectUser(Long userId) {
        log.info("사용자 정보 조회 - userId: {}", userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        return UserDto.from(user);
    }

    @Transactional
    public UserDto updateUser(Long userId, UserUpdateDto dto) {
        log.info("사용자 정보 수정 시작 - userId: {}", userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        user.updateInfo(dto.getName(), dto.getPhoneNumber());
        log.info("사용자 정보 수정 완료 - userId: {}", userId);

        return UserDto.from(user);
    }

    @Transactional
    public void changePassword(Long userId, PasswordChangeDto dto) {
        log.info("비밀번호 변경 시작 - userId: {}", userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        if (!user.getPassword().equals(dto.getCurrentPassword())) {
            throw new BusinessException(ErrorCode.INVALID_CREDENTIALS, "현재 비밀번호가 일치하지 않습니다");
        }

        user.changePassword(dto.getNewPassword());
        log.info("비밀번호 변경 완료 - userId: {}", userId);
    }
}
