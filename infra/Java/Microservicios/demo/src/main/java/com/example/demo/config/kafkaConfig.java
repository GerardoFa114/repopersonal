package com.example.demo.config;

import org.springframework.beans.factory.annotation.Value;
import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class kafkaConfig {

    @Value("${topic.ordenes}")
    private String topicOrdenes;

    @Bean
    public NewTopic ordenesTopic() {
        return TopicBuilder.name(topicOrdenes)
                .partitions(1)
                .replicas(1)
                .build();
    }
}