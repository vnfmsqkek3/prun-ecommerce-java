package com.example.ecommercedemo.controller;

import com.example.ecommercedemo.service.MediaService;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

// POST /api/media (multipart) → { "url": "/media/<uuid>.<ext>" }
// 반환된 url 을 상품 image_url 등에 저장하면 CloudFront /media 로 서빙됨.
@RestController
@RequestMapping("/api/media")
@Profile("prod")
public class MediaController {

    private final MediaService mediaService;

    public MediaController(MediaService mediaService) {
        this.mediaService = mediaService;
    }

    @PostMapping
    public ResponseEntity<Map<String, String>> upload(@RequestParam("file") MultipartFile file) {
        return ResponseEntity.ok(Map.of("url", mediaService.upload(file)));
    }
}
