<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>

<%
// ===== DETERMINAR QUÉ TIPO DE USUARIO ES =====
// Esto nos ayuda a mostrar el menú de navegación correcto
boolean isLoggedIn = session.getAttribute("usuario") != null;   // ¿Está logueado?
boolean isAdmin = "admin".equals(session.getAttribute("tipo_usuario")); // ¿Es administrador?
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sakura Bites - Menú</title>
    <link rel="stylesheet" href="CSS/styles.css">
</head>
<body>
    <!-- ===== ENCABEZADO DINÁMICO =====
         El menú cambia dependiendo de quién esté viendo la página -->
    <header>
        <h1>🌸 Sakura Bites 🌸</h1>
        <nav>
            <img src="Imagenes/LogoSakuraBites.png" alt="Logo Sakura Bites" width="100">
            
            <%
            // Mostrar navegación diferente para cada tipo de usuario
            if (isAdmin) {
                // ===== NAVEGACIÓN PARA ADMINISTRADORES =====
            %>
                <a href="Admin.jsp">Panel Admin</a>
                <a href="Menu.jsp">Menú</a>
                <a href="Inventario.jsp">Inventario</a>
                <a href="Horarios.jsp">Horarios</a>
                <a href="RegistrarPedido.jsp">Registrar Pedido</a>
            <%
            } else if (isLoggedIn) {
                // ===== NAVEGACIÓN PARA CLIENTES LOGUEADOS =====
            %>
                <a href="HomeCliente.jsp">Inicio</a>
                <a href="Menu.jsp">Menú</a>
                <a href="ConsultarPedido.jsp">Mis Pedidos</a>
                <a href="Carrito.jsp">Carrito</a>
                <a href="Contacto.jsp">Contacto</a>
            <%
            } else {
                // ===== NAVEGACIÓN PARA VISITANTES (NO LOGUEADOS) =====
            %>
                <a href="Home.jsp">Inicio</a>
                <a href="Nosotros.jsp">Sobre Nosotros</a>
                <a href="Menu.jsp">Menú</a>
                <a href="login.jsp">Login</a>
                <a href="Registro.jsp">Registro</a>
            <%
            }
            %>
            <a href="https://www.google.com" target="_blank">🔍</a>
        </nav>
    </header>

    <!-- ===== CONTENIDO PRINCIPAL ===== -->
    <section>
        <h2>Nuestro Delicioso Menú</h2>
        
        <!-- Decoración temática -->
        <div class="dango-decoration dango-rosa"></div>
        <div class="dango-decoration dango-verde"></div>
        <div class="dango-decoration dango-crema"></div>

        <!-- ===== FILTROS DE BÚSQUEDA ===== -->
        <h3>Buscar Platillos</h3>
        <form action="Menu.jsp" method="get">
            <select name="categoria_filtro">
                <option value="">Todas las categorías</option>
                <option value="entrada">Entradas</option>
                <option value="plato_principal">Platos Principales</option>
                <option value="postre">Postres</option>
                <option value="bebida">Bebidas</option>
            </select>
            <input type="submit" value="Buscar">
        </form>

        <!-- ===== OBTENER PARÁMETROS DE BÚSQUEDA ===== -->
        <%
        String buscar = request.getParameter("buscar");
        String categoriaFiltro = request.getParameter("categoria_filtro");
        %>

        <!-- ===== MOSTRAR PRODUCTOS ===== -->
        <div class="menu-items">
            <%@ page import="java.sql.*" %>
            <%
            // Variables para la base de datos
            Connection con = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;

            try {
                // ===== CONECTAR A LA BASE DE DATOS =====
                Class.forName("com.mysql.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
                
                // ===== CONSTRUIR CONSULTA DINÁMICA =====
                // Empezamos con una consulta básica y le agregamos filtros según lo que busque el usuario
                String query = "SELECT * FROM productos WHERE activo = TRUE";
                
                // Si el usuario escribió algo para buscar, agregamos esa condición
                if (buscar != null && !buscar.trim().isEmpty()) {
                    query += " AND (nombre LIKE ? OR descripcion LIKE ?)";
                }
                
                // Si seleccionó una categoría específica, la agregamos
                if (categoriaFiltro != null && !categoriaFiltro.isEmpty()) {
                    query += " AND categoria = ?";
                }
                
                // Ordenar los resultados por categoría y luego por nombre
                query += " ORDER BY categoria, nombre";
                
                // ===== PREPARAR Y EJECUTAR LA CONSULTA =====
                stmt = con.prepareStatement(query);
                
                // Llenar los parámetros de búsqueda (los signos de interrogación)
                int paramIndex = 1;
                if (buscar != null && !buscar.trim().isEmpty()) {
                    // Buscar en nombre y descripción (el % significa "cualquier cosa antes o después")
                    stmt.setString(paramIndex++, "%" + buscar + "%");
                    stmt.setString(paramIndex++, "%" + buscar + "%");
                }
                if (categoriaFiltro != null && !categoriaFiltro.isEmpty()) {
                    stmt.setString(paramIndex++, categoriaFiltro);
                }
                
                // Ejecutar la consulta
                rs = stmt.executeQuery();
                
                // ===== MOSTRAR CADA PRODUCTO =====
                while (rs.next()) {
                    // Obtener información de cada producto
                    int id = rs.getInt("id_producto");
                    String nombre = rs.getString("nombre");
                    String descripcion = rs.getString("descripcion");
                    double precio = rs.getDouble("precio");
                    int stock = rs.getInt("stock");
            %>
                    <!-- ===== CARD DE PRODUCTO ===== -->
                    <div class="producto-card">
                        <h4><%= nombre %></h4>
                        <p class="small-text"><%= descripcion %></p>
                        <p class="precio">$<%= String.format("%.2f", precio) %></p>
                        
                        <%
                        // ===== MOSTRAR BOTONES SEGÚN EL TIPO DE USUARIO =====
                        if (stock > 0) {
                            if (isLoggedIn && !isAdmin) {
                                // Cliente logueado: puede agregar al carrito
                        %>
                                <form action="AgregarCarrito.jsp" method="post">
                                    <input type="hidden" name="id_producto" value="<%= id %>">
                                    <input type="submit" value="Agregar al carrito" class="btn-agregar">
                                </form>
                        <%
                            } else if (!isLoggedIn) {
                                // Visitante: debe iniciar sesión primero
                        %>
                                <a href="login.jsp"><button>Iniciar sesión para ordenar</button></a>
                        <%
                            } else {
                                // Admin: solo ve el stock
                        %>
                                <span class="muted">Stock: <%= stock %></span>
                        <%
                            }
                        } else {
                            // Producto agotado
                        %>
                            <span class="error">Agotado</span>
                        <%
                        }
                        %>
                    </div>
            <%
                }
                
                // Si no se encontraron productos con la búsqueda
                if (!rs.isBeforeFirst() && buscar != null && !buscar.trim().isEmpty()) {
            %>
                    <p>No se encontraron productos con "<%= buscar %>"</p>
            <%
                }
                
            } catch (Exception e) {
                // Si hay error con la base de datos, mostrar mensaje amigable
                out.println("<p class='error'>Error al cargar productos: " + e.getMessage() + "</p>");
            } finally {
                // ===== SIEMPRE CERRAR LAS CONEXIONES =====
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (con != null) con.close();
            }
            %>
        </div>
    </section>

    <!-- ===== PIE DE PÁGINA DINÁMICO ===== -->
    <footer>
        <nav>
            <%
            // El footer también cambia según el tipo de usuario
            if (isAdmin) {
            %>
                <a href="Admin.jsp">Panel Admin</a> |
                <a href="Inventario.jsp">Inventario</a> |
                <a href="Horarios.jsp">Horarios</a> |
            <%
            } else if (isLoggedIn) {
            %>
                <a href="HomeCliente.jsp">Inicio</a> |
                <a href="Menu.jsp">Menú</a> |
                <a href="ConsultarPedido.jsp">Mis Pedidos</a> |
            <%
            } else {
            %>
                <a href="home.jsp">Inicio</a> |
                <a href="Nosotros.jsp">Sobre Nosotros</a> |
                <a href="Menu.jsp">Menú</a> |
            <%
            }
            %>
            <a href="Logout.jsp">Logout</a>
        </nav>
        <p>&copy; 2025 Sakura Bites. Todos los derechos reservados.</p>
    </footer>
</body>
</html>