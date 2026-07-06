package com.example.ecommercedemo.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;

// 미디어 업로드용 S3 클라이언트. prod 에서만 (로컬은 S3/자격증명 불필요).
// 자격증명은 인스턴스 프로파일(DefaultCredentialsProvider), 트래픽은 VPC S3 endpoint 경유.
@Configuration
@Profile("prod")
public class S3Config {

    @Bean
    public S3Client s3Client(@Value("${AWS_REGION:ap-northeast-2}") String region) {
        return S3Client.builder()
                .region(Region.of(region))
                .credentialsProvider(DefaultCredentialsProvider.create())
                .build();
    }
}
