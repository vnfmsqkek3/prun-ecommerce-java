package com.example.ecommercedemo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class EcommerceDemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(EcommerceDemoApplication.class, args);
    }

}
