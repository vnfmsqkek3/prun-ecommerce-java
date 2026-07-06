package com.example.ecommercedemo.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.IOException;
import java.util.UUID;

// 업로드 파일을 media 버킷에 저장(S3 endpoint 경유)하고 CloudFront /media 경로를 반환.
@Service
@Profile("prod")
public class MediaService {

    private final S3Client s3;
    private final String bucket;

    public MediaService(S3Client s3, @Value("${MEDIA_BUCKET}") String bucket) {
        this.s3 = s3;
        this.bucket = bucket;
    }

    public String upload(MultipartFile file) {
        String key = "media/" + UUID.randomUUID() + extension(file.getOriginalFilename());
        try {
            s3.putObject(
                    PutObjectRequest.builder()
                            .bucket(bucket)
                            .key(key)
                            .contentType(file.getContentType())
                            .build(),
                    RequestBody.fromInputStream(file.getInputStream(), file.getSize()));
        } catch (IOException e) {
            throw new RuntimeException("미디어 업로드 실패", e);
        }
        // 같은 CloudFront 도메인의 상대 경로 → 어느 도메인에서든 동작
        return "/" + key;
    }

    private String extension(String name) {
        if (name == null) {
            return "";
        }
        int i = name.lastIndexOf('.');
        return i >= 0 ? name.substring(i) : "";
    }
}
