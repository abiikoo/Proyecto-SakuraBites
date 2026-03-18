<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
// Verificar si el usuario es admin
if (session.getAttribute("usuario") == null || !"admin".equals(session.getAttribute("tipo_usuario"))) {
    response.sendRedirect("login.jsp");
    return;
}

// Obtener parámetros del formulario
String idProductoStr = request.getParameter("id_producto");
String nombre = request.getParameter("nombre");
String descripcion = request.getParameter("descripcion");
String categoria = request.getParameter("categoria");
String precioStr = request.getParameter("precio");
String stockStr = request.getParameter("stock");
String stockMinimoStr = request.getParameter("stock_minimo");

// Variables para el resultado
boolean exito = false;
String mensaje = "";

// DEBUG: Imprimir valores recibidos
System.out.println("=== DEBUG GUARDAR PRODUCTO ===");
System.out.println("ID Producto: [" + idProductoStr + "]");
System.out.println("Nombre: [" + nombre + "]");
System.out.println("Descripcion: [" + descripcion + "]");
System.out.println("Categoria: [" + categoria + "]");
System.out.println("Precio: [" + precioStr + "]");
System.out.println("Stock: [" + stockStr + "]");
System.out.println("Stock Minimo: [" + stockMinimoStr + "]");

// Validar que no vengan datos vacíos
if (nombre == null || nombre.trim().isEmpty() || 
    categoria == null || categoria.trim().isEmpty() ||
    precioStr == null || precioStr.trim().isEmpty() ||
    stockStr == null || stockStr.trim().isEmpty() ||
    stockMinimoStr == null || stockMinimoStr.trim().isEmpty()) {
    
    mensaje = "Todos los campos son obligatorios";
    System.out.println("ERROR: Campos obligatorios vacíos");
} else {
    Connection con = null;
    PreparedStatement pstmt = null;
    
    try {
        // Convertir valores numéricos
        double precio = Double.parseDouble(precioStr.trim());
        int stock = Integer.parseInt(stockStr.trim());
        int stockMinimo = Integer.parseInt(stockMinimoStr.trim());
        
        System.out.println("Valores convertidos - Precio: " + precio + ", Stock: " + stock + ", Stock Min: " + stockMinimo);
        
        // Conectar a la base de datos
        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
        con.setAutoCommit(true); // Asegurar que los cambios se confirmen automáticamente
        
        // Verificar si es una actualización o inserción
        if (idProductoStr != null && !idProductoStr.trim().isEmpty() && !"".equals(idProductoStr.trim())) {
            // ACTUALIZAR producto existente
            int idProducto = Integer.parseInt(idProductoStr.trim());
            System.out.println("MODO: UPDATE - ID: " + idProducto);
            
            // Primero verificar que el producto existe
            PreparedStatement checkStmt = con.prepareStatement("SELECT id_producto FROM productos WHERE id_producto = ?");
            checkStmt.setInt(1, idProducto);
            ResultSet checkRs = checkStmt.executeQuery();
            
            if (checkRs.next()) {
                System.out.println("Producto encontrado, procediendo con UPDATE");
                
                String sqlUpdate = "UPDATE productos SET nombre=?, descripcion=?, categoria=?, precio=?, stock=?, stock_minimo=? WHERE id_producto=?";
                pstmt = con.prepareStatement(sqlUpdate);
                pstmt.setString(1, nombre.trim());
                pstmt.setString(2, descripcion != null ? descripcion.trim() : "");
                pstmt.setString(3, categoria.trim());
                pstmt.setDouble(4, precio);
                pstmt.setInt(5, stock);
                pstmt.setInt(6, stockMinimo);
                pstmt.setInt(7, idProducto);
                
                System.out.println("Ejecutando SQL: " + sqlUpdate);
                System.out.println("Parámetros: [" + nombre.trim() + ", " + (descripcion != null ? descripcion.trim() : "") + ", " + categoria.trim() + ", " + precio + ", " + stock + ", " + stockMinimo + ", " + idProducto + "]");
                
                int filasAfectadas = pstmt.executeUpdate();
                System.out.println("Filas afectadas: " + filasAfectadas);
                
                if (filasAfectadas > 0) {
                    exito = true;
                    mensaje = "Producto actualizado correctamente";
                    System.out.println("SUCCESS: Producto actualizado");
                } else {
                    mensaje = "Error: No se pudo actualizar el producto (0 filas afectadas)";
                    System.out.println("ERROR: 0 filas afectadas en UPDATE");
                }
            } else {
                mensaje = "Error: El producto con ID " + idProducto + " no existe";
                System.out.println("ERROR: Producto no encontrado con ID: " + idProducto);
            }
            
            checkRs.close();
            checkStmt.close();
            
        } else {
            // INSERTAR nuevo producto
            System.out.println("MODO: INSERT - Nuevo producto");
            
            String sqlInsert = "INSERT INTO productos (nombre, descripcion, categoria, precio, stock, stock_minimo, activo) VALUES (?, ?, ?, ?, ?, ?, TRUE)";
            pstmt = con.prepareStatement(sqlInsert);
            pstmt.setString(1, nombre.trim());
            pstmt.setString(2, descripcion != null ? descripcion.trim() : "");
            pstmt.setString(3, categoria.trim());
            pstmt.setDouble(4, precio);
            pstmt.setInt(5, stock);
            pstmt.setInt(6, stockMinimo);
            
            System.out.println("Ejecutando SQL: " + sqlInsert);
            
            int filasAfectadas = pstmt.executeUpdate();
            System.out.println("Filas afectadas: " + filasAfectadas);
            
            if (filasAfectadas > 0) {
                exito = true;
                mensaje = "Producto agregado correctamente";
                System.out.println("SUCCESS: Producto agregado");
            } else {
                mensaje = "Error: No se pudo agregar el producto (0 filas afectadas)";
                System.out.println("ERROR: 0 filas afectadas en INSERT");
            }
        }
        
    } catch (NumberFormatException e) {
        mensaje = "Error: Formato de número inválido - " + e.getMessage();
        System.out.println("ERROR NumberFormat: " + e.getMessage());
        e.printStackTrace();
    } catch (SQLException e) {
        mensaje = "Error de base de datos: " + e.getMessage();
        System.out.println("ERROR SQL: " + e.getMessage());
        e.printStackTrace();
    } catch (Exception e) {
        mensaje = "Error inesperado: " + e.getMessage();
        System.out.println("ERROR General: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (pstmt != null) {
            try { pstmt.close(); } catch (SQLException e) {}
        }
        if (con != null) {
            try { con.close(); } catch (SQLException e) {}
        }
    }
}

System.out.println("Resultado final - Exito: " + exito + ", Mensaje: " + mensaje);
System.out.println("=== FIN DEBUG ===");

// Redireccionar de vuelta a Inventario.jsp con mensaje
if (exito) {
    // Redireccionar con mensaje de éxito
    response.sendRedirect("Inventario.jsp?mensaje=" + java.net.URLEncoder.encode(mensaje, "UTF-8") + "&tipo=exito");
} else {
    // Redireccionar con mensaje de error
    response.sendRedirect("Inventario.jsp?mensaje=" + java.net.URLEncoder.encode(mensaje, "UTF-8") + "&tipo=error");
}
%>