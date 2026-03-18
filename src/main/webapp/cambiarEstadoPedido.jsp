/* ================================================
   CAMBIARESTADOPEDIDO.JSP - CAMBIAR ESTADO DE PEDIDOS
   Archivo de procesamiento para que los admins cambien el estado de los pedidos
   ================================================ */

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
// ===== VERIFICAR PERMISOS DE ADMINISTRADOR =====
if (session.getAttribute("usuario") == null || !"admin".equals(session.getAttribute("tipo_usuario"))) {
    response.sendRedirect("login.jsp");
    return;
}

// ===== OBTENER DATOS DEL FORMULARIO =====
String idPedido = request.getParameter("id_pedido");
String nuevoEstado = request.getParameter("nuevo_estado");

// ===== VERIFICAR QUE TENEMOS LOS DATOS NECESARIOS =====
if (idPedido != null && nuevoEstado != null && !nuevoEstado.isEmpty()) {
    
    Connection con = null;
    PreparedStatement stmt = null;
    
    try {
        // ===== CONECTAR A LA BASE DE DATOS =====
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
        
        // ===== ACTUALIZAR EL ESTADO DEL PEDIDO =====
        String sql = "UPDATE pedidos SET estado = ? WHERE id_pedido = ?";
        stmt = con.prepareStatement(sql);
        stmt.setString(1, nuevoEstado);  // El nuevo estado seleccionado
        stmt.setString(2, idPedido);     // El ID del pedido a actualizar
        
        stmt.executeUpdate();  // Ejecutar la actualización
        
    } catch (Exception e) {
        // ===== MANEJO DE ERRORES =====
        e.printStackTrace();  // Log del error para debugging
    } finally {
        // ===== LIMPIEZA DE CONEXIONES =====
        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
}

// ===== REDIRIGIR DE VUELTA AL DETALLE =====
// Después de cambiar el estado, volvemos a la página de detalle del pedido
response.sendRedirect("detallePedidoAdmin.jsp?id=" + idPedido);
%>
