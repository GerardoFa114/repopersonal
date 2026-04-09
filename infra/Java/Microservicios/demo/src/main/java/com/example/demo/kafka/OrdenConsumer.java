package com.example.demo.kafka;


import com.example.demo.event.OrdenCreadaEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class OrdenConsumer {

    private static final Logger log = LoggerFactory.getLogger(OrdenConsumer.class);

    @KafkaListener(topics = "${topic.ordenes}", groupId = "ordenes-group")
    public void consumir(OrdenCreadaEvent event) {
        log.info("Evento recibido desde Kafka -> id={}, cliente={}, producto={}, monto={}, estado={}",
                event.getId(),
                event.getCliente(),
                event.getProducto(),
                event.getMonto(),
                event.getEstado());
    }
}