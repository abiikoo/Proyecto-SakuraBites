<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>

<%
// ===== CERRAR SESIÓN COMPLETAMENTE =====
// Esto elimina toda la información guardada en la sesión del usuario
session.invalidate();

// ===== REDIRIGIR AL LOGIN =====
// Después de cerrar sesión, enviar al usuario de vuelta al login
response.sendRedirect("login.jsp");
%>