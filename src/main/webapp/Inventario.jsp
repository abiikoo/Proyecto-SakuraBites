<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
// ===== SEGURIDAD: VERIFICAR QUE SEA ADMINISTRADOR =====
// Si no es admin, lo enviamos al login
if (session.getAttribute("usuario") == null || !"admin".equals(session.getAttribute("tipo_usuario"))) {
    response.sendRedirect("login.jsp");
    return;
}

// ===== OBTENER MENSAJES DE FEEDBACK =====
// Cuando se guarda un producto, se envían mensajes de confirmación
String mensaje = request.getParameter("mensaje");
String tipoMensaje = request.getParameter("tipo");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Inventario - Sakura Bites Admin</title>
    <link rel="stylesheet" href="CSS/styles.css">
</head>
<body>
    <!-- ===== ENCABEZADO DE ADMIN ===== -->
    <header>
        <h1>🌸 Sakura Bites 🌸</h1>
        <nav>
            <img src="Imagenes/LogoSakuraBites.png" alt="Logo Sakura Bites" width="100">
            <!-- Navegación específica para administradores -->
            <a href="Admin.jsp">Panel Admin</a>
            <a href="Inventario.jsp">Inventario</a>
            <a href="Horarios.jsp">Horarios</a>
            <a href="Historial.jsp">Historial de Pedidos</a>
            <a href="RegistrarPedido.jsp">Registrar Pedido</a>
            <a href="https://www.google.com" target="_blank">🔍</a>
        </nav>
    </header>

    <section>
        <h1>Gestión de Inventario</h1>
        
        <!-- ===== MOSTRAR MENSAJES DE FEEDBACK ===== -->
        <!-- Cuando se agrega o edita un producto, se muestra un mensaje aquí -->
        <% if (mensaje != null && !mensaje.trim().isEmpty()) { %>
            <div class="mensaje <%= tipoMensaje != null ? tipoMensaje : "info" %>">
                <%= mensaje %>
            </div>
        <% } %>
        
        <!-- ===== BOTÓN PARA AGREGAR NUEVO PRODUCTO ===== -->
        <div class="mb-20">
            <button onclick="mostrarFormulario()" class="btn-primary">+ Agregar Producto</button>
        </div>
        
        <!-- ===== FORMULARIO PARA AGREGAR/EDITAR ===== -->
        <!-- Por defecto está oculto, se muestra con JavaScript -->
        <div id="formularioProducto" class="formulario-producto oculto">
            <form action="guardarProducto.jsp" method="post" class="form-inventario">
                <h3>Agregar/Editar Producto</h3>
                
                <!-- Campo oculto para el ID (solo cuando se edita) -->
                <input type="hidden" id="id_producto" name="id_producto">
                
                <!-- Información básica del producto -->
                <div class="form-group">
                    <label for="nombre">Nombre del Producto:</label>
                    <input type="text" id="nombre" name="nombre" required>
                </div>
                
                <div class="form-group">
                    <label for="descripcion">Descripción:</label>
                    <textarea id="descripcion" name="descripcion" rows="3"></textarea>
                </div>
                
                <!-- Categoría del producto -->
                <div class="form-group">
                    <label for="categoria">Categoría:</label>
                    <select id="categoria" name="categoria" required>
                        <option value="">Seleccione...</option>
                        <option value="entrada">Entrada</option>
                        <option value="plato_principal">Plato Principal</option>
                        <option value="postre">Postre</option>
                        <option value="bebida">Bebida</option>
                    </select>
                </div>
                
                <!-- Información numérica (precio y stock) -->
                <div class="form-row">
                    <div class="form-group">
                        <label for="precio">Precio:</label>
                        <input type="number" id="precio" name="precio" step="0.01" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="stock">Stock Actual:</label>
                        <input type="number" id="stock" name="stock" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="stock_minimo">Stock Mínimo:</label>
                        <input type="number" id="stock_minimo" name="stock_minimo" required>
                    </div>
                </div>
                
                <!-- Botones del formulario -->
                <div class="form-buttons">
                    <input type="submit" value="Guardar" class="btn-success">
                    <button type="button" onclick="ocultarFormulario()" class="btn-secondary">Cancelar</button>
                </div>
            </form>
        </div>
        
        <!-- ===== TABLA DE PRODUCTOS EXISTENTES ===== -->
        <div class="tabla-container">
            <table class="tabla-inventario">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nombre</th>
                        <th>Categoría</th>
                        <th>Precio</th>
                        <th>Stock Actual</th>
                        <th>Stock Mínimo</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    // ===== CARGAR PRODUCTOS DE LA BASE DE DATOS =====
                    Connection con = null;
                    Statement stmt = null;
                    ResultSet rs = null;
                    
                    try {
                        // Conectar y obtener todos los productos
                        Class.forName("com.mysql.jdbc.Driver");
                        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
                        stmt = con.createStatement();
                        rs = stmt.executeQuery("SELECT * FROM productos ORDER BY categoria, nombre");
                        
                        // ===== MOSTRAR CADA PRODUCTO EN UNA FILA =====
                        while (rs.next()) {
                            int stock = rs.getInt("stock");
                            int stockMinimo = rs.getInt("stock_minimo");
                            
                            // Determinar el estado del stock
                            String estado = stock <= stockMinimo ? "Bajo" : "Normal";
                            String claseEstado = stock <= stockMinimo ? "estado-bajo" : "estado-normal";
                    %>
                    <tr>
                        <td><%= rs.getInt("id_producto") %></td>
                        <td><%= rs.getString("nombre") %></td>
                        <td><%= rs.getString("categoria") %></td>
                        <td>$<%= String.format("%.2f", rs.getDouble("precio")) %></td>
                        <td><%= stock %></td>
                        <td><%= stockMinimo %></td>
                        <td><span class="<%= claseEstado %>"><%= estado %></span></td>
                        <td>
                            <!-- Botón para editar (llena el formulario con los datos actuales) -->
                            <button onclick="editarProducto(
                                <%= rs.getInt("id_producto") %>, 
                                '<%= rs.getString("nombre").replace("'", "\\'") %>', 
                                '<%= rs.getString("descripcion") != null ? rs.getString("descripcion").replace("'", "\\'") : "" %>', 
                                '<%= rs.getString("categoria") %>', 
                                <%= rs.getDouble("precio") %>, 
                                <%= stock %>, 
                                <%= stockMinimo %>
                            )" class="btn-edit">Editar</button>
                        </td>
                    </tr>
                    <%
                        }
                    } catch (Exception e) {
                        // Si hay error, mostrar mensaje en la tabla
                        out.println("<tr><td colspan='8' class='error'>Error al cargar inventario: " + e.getMessage() + "</td></tr>");
                    } finally {
                        // Cerrar conexiones
                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                        if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                        if (con != null) try { con.close(); } catch (SQLException e) {}
                    }
                    %>
                </tbody>
            </table>
        </div>
    </section>

    <!-- ===== PIE DE PÁGINA ===== -->
    <footer>
        <nav>
            <a href="Admin.jsp">Panel Admin</a> |
            <a href="Inventario.jsp">Inventario</a> |
            <a href="Horarios.jsp">Horarios</a> |
            <a href="Logout.jsp">Logout</a>
        </nav>
        <p>&copy; 2025 Sakura Bites. Todos los derechos reservados.</p>
    </footer>

    <!-- ===== JAVASCRIPT PARA INTERACTIVIDAD ===== -->
    <script>
        // ===== MOSTRAR EL FORMULARIO =====
        function mostrarFormulario() {
            document.getElementById('formularioProducto').classList.remove('oculto');
        }
        
        // ===== OCULTAR EL FORMULARIO =====
        function ocultarFormulario() {
            document.getElementById('formularioProducto').classList.add('oculto');
            limpiarFormulario(); // También limpiar los campos
        }
        
        // ===== LIMPIAR TODOS LOS CAMPOS DEL FORMULARIO =====
        function limpiarFormulario() {
            document.getElementById('id_producto').value = '';
            document.getElementById('nombre').value = '';
            document.getElementById('descripcion').value = '';
            document.getElementById('categoria').value = '';
            document.getElementById('precio').value = '';
            document.getElementById('stock').value = '';
            document.getElementById('stock_minimo').value = '';
        }
        
        // ===== LLENAR EL FORMULARIO PARA EDITAR =====
        // Esta función se llama cuando alguien hace clic en "Editar"
        function editarProducto(id, nombre, descripcion, categoria, precio, stock, stockMinimo) {
            document.getElementById('id_producto').value = id;
            document.getElementById('nombre').value = nombre;
            document.getElementById('descripcion').value = descripcion;
            document.getElementById('categoria').value = categoria;
            document.getElementById('precio').value = precio;
            document.getElementById('stock').value = stock;
            document.getElementById('stock_minimo').value = stockMinimo;
            mostrarFormulario(); // Mostrar el formulario ya lleno
        }
        
        // ===== AUTO-OCULTAR MENSAJES =====
        // Los mensajes de éxito/error desaparecen automáticamente después de 5 segundos
        setTimeout(function() {
            const mensaje = document.querySelector('.mensaje');
            if (mensaje) {
                mensaje.style.opacity = '0';
                setTimeout(() => mensaje.remove(), 300);
            }
        }, 5000);
    </script>
</body>
</html>