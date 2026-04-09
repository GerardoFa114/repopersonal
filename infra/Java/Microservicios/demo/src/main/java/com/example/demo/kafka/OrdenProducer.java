package com.example.demo.kafka;

import com.example.demo.event.OrdenCreadaEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
public class OrdenProducer {

    private static final Logger log = LoggerFactory.getLogger(OrdenProducer.class);

    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Value("${topic.ordenes}")
    private String topicOrdenes;

    public OrdenProducer(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void publicarOrdenCreada(OrdenCreadaEvent event) {
        String key = String.valueOf(event.getId());
        kafkaTemplate.send(topicOrdenes, key, event);
        log.info("Evento enviado a Kafka. topic={}, key={}", topicOrdenes, key);
    }
}