package com.example.ticketing.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "concerts")
@Getter
@NoArgsConstructor
public class Concert {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    private String artist;
    private String venue;
    private LocalDateTime concertDate;

    @Column(length = 500)
    private String imageUrl;

    public Concert(String title, String artist, String venue, LocalDateTime concertDate, String imageUrl) {
        this.title = title;
        this.artist = artist;
        this.venue = venue;
        this.concertDate = concertDate;
        this.imageUrl = imageUrl;
    }
}
