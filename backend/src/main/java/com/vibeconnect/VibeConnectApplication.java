package com.vibeconnect;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
@EnableJpaRepositories(basePackages = "com.vibeconnect.repository")
public class VibeConnectApplication {

    public static void main(String[] args) {
        SpringApplication.run(VibeConnectApplication.class, args);
    }
}

