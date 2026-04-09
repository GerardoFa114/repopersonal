package com.example.demo.service;


import com.example.demo.dto.OrdenRequest;
import com.example.demo.dto.OrdenResponse;
import com.example.demo.entity.OrdenEntity;
import com.example.demo.event.OrdenCreadaEvent;
import com.example.demo.kafka.OrdenProducer;
import com.example.demo.repository.OrdenRepository;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

@Service
public class OrdenService   {
private final OrdenRepository ordenRepository;
private final OrdenProducer ordenProducer;

public OrdenService(OrdenRepository ordenRepository, OrdenProducer ordenProducer) {
    this.ordenRepository = ordenRepository;
    this.ordenProducer = ordenProducer;
}

@Transactional
public OrdenResponse crearOrden(OrdenRequest request) {
    OrdenEntity entity = new OrdenEntity();
    entity.setCliente(request.getCliente());
    entity.setProducto(request.getProducto());
    entity.setMonto(request.getMonto());
    entity.setEstado(request.getEstado());

    OrdenEntity guardada = ordenRepository.save(entity);

    OrdenCreadaEvent event = new OrdenCreadaEvent(
            guardada.getId(),
            guardada.getCliente(),
            guardada.getProducto(),
            guardada.getMonto(),
            guardada.getEstado()
    );

    ordenProducer.publicarOrdenCreada(event);

    return new OrdenResponse(
            guardada.getId(),
            guardada.getCliente(),
            guardada.getProducto(),
            guardada.getMonto(),
            guardada.getEstado()
    );
}
}
