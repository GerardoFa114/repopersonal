package com.example.demo.event;


import java.math.BigDecimal;

public class OrdenCreadaEvent {

    private Long id;
    private String cliente;
    private String producto;
    private BigDecimal monto;
    private String estado;

    public OrdenCreadaEvent() {
    }

    public OrdenCreadaEvent(Long id, String cliente, String producto, BigDecimal monto, String estado) {
        this.id = id;
        this.cliente = cliente;
        this.producto = producto;
        this.monto = monto;
        this.estado = estado;
    }

    public Long getId() {
        return id;
    }

    public String getCliente() {
        return cliente;
    }

    public String getProducto() {
        return producto;
    }

    public BigDecimal getMonto() {
        return monto;
    }

    public String getEstado() {
        return estado;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setCliente(String cliente) {
        this.cliente = cliente;
    }

    public void setProducto(String producto) {
        this.producto = producto;
    }

    public void setMonto(BigDecimal monto) {
        this.monto = monto;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
}