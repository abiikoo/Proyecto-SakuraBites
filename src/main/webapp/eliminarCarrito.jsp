/* ================================================
   ELIMINARCARRITO.JSP - ELIMINAR PRODUCTOS DEL CARRITO
   Archivo de procesamiento para quitar productos del carrito
   ================================================ */

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
// ===== VERIFICAR QUE EL USUARIO ESTÉ LOGUEADO =====
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

// ===== OBTENER DATOS =====
String idCarrito = request.getParameter("id_carrito");    // ¿Qué elemento eliminar?
String idUsuario = (String) session.getAttribute("usuario_id");  // ¿Quién lo está eliminando?

// ===== VERIFICAR QUE TENEMOS LOS DATOS NECESARIOS =====
if (idCarrito != null) {
    
    Connection con = null;
    PreparedStatement stmt = null;
    
    try {
        // ===== CONECTAR A LA BASE DE DATOS =====
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
        
        // ===== ELIMINAR CON SEGURIDAD =====
        // IMPORTANTE: Verificamos que el producto pertenezca al usuario actual
        // Esto evita que alguien elimine productos del carrito de otra persona
        String sql = "DELETE FROM carrito WHERE id_carrito = ? AND id_usuario = ?";
        stmt = con.prepareStatement(sql);
        stmt.setString(1, idCarrito);  // El ID del elemento en el carrito
        stmt.setString(2, idUsuario);  // El ID del usuario (por seguridad)
        
        stmt.executeUpdate();  // Ejecutar la eliminación
        
    } catch (Exception e) {
        // ===== MANEJO DE ERRORES =====
        e.printStackTrace();  // Log del error
    } finally {
        // ===== LIMPIEZA DE CONEXIONES =====
        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
}

// ===== REDIRIGIR DE VUELTA AL CARRITO =====
// Después de eliminar, volvemos al carrito para que el usuario vea los cambios
response.sendRedirect("Carrito.jsp");
%>