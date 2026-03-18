/* ================================================
   EDITARPEDIDO.JSP - REDIRECCIÓN PARA EDITAR PEDIDOS
   Archivo simple que redirige al detalle donde se puede cambiar el estado
   ================================================ */

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
// ===== REDIRECCIÓN SIMPLE =====
// En lugar de tener una página separada para editar pedidos,
// redirigimos al detalle del pedido donde está la funcionalidad de cambiar estado

String idPedido = request.getParameter("id");  // Obtener el ID del pedido
response.sendRedirect("detallePedidoAdmin.jsp?id=" + idPedido);  // Redirigir al detalle
%>
