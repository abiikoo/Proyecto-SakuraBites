<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
// ===== SECCIÓN DE PROCESAMIENTO DEL FORMULARIO =====
// Esta parte se ejecuta cuando alguien envía el formulario de registro

String mensaje = "";           // Para mostrar mensajes al usuario
String tipoMensaje = "";       // "error" o "success" para darle color al mensaje

// Verificar si alguien está enviando datos (método POST)
if ("POST".equalsIgnoreCase(request.getMethod())) {
    
    // ===== RECOGER DATOS DEL FORMULARIO =====
    // Obtenemos toda la información que el usuario escribió
    String nombre = request.getParameter("nombre");
    String correo = request.getParameter("correo");
    String telefono = request.getParameter("telefono");
    String clave = request.getParameter("clave");
    String confirmarClave = request.getParameter("confirmar_clave");
    String tipoUsuario = request.getParameter("tipo_usuario");
    
    // ===== VALIDACIÓN BÁSICA =====
    // Verificar que las contraseñas coincidan
    if (!clave.equals(confirmarClave)) {
        mensaje = "Las contraseñas no coinciden";
        tipoMensaje = "error";
    } else {
        // ===== CONEXIÓN A BASE DE DATOS =====
        // Preparamos las herramientas para trabajar con la base de datos
        Connection con = null;                    // La conexión a la base de datos
        PreparedStatement stmtUsuario = null;     // Para insertar en tabla usuarios
        PreparedStatement stmtCliente = null;     // Para insertar en tabla clientes
        
        try {
            // Conectar a MySQL (como abrir la puerta de la base de datos)
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakura_bites", "root", "");
            con.setAutoCommit(false); // Modo transacción - si algo falla, se cancela todo
            
            // ===== PASO 1: CREAR USUARIO =====
            // Insertar los datos básicos del usuario
            String sqlUsuario = "INSERT INTO usuarios (correo, clave, tipo_usuario) VALUES (?, ?, ?)";
            stmtUsuario = con.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS);
            stmtUsuario.setString(1, correo);        // Email del usuario
            stmtUsuario.setString(2, clave);         // Contraseña (en la vida real debería estar encriptada)
            stmtUsuario.setString(3, tipoUsuario);   // "cliente" o "admin"
            
            int filasUsuario = stmtUsuario.executeUpdate(); // Ejecutar la inserción
            
            if (filasUsuario > 0) {
                // ===== PASO 2: OBTENER ID DEL USUARIO CREADO =====
                // Necesitamos el ID que se generó automáticamente
                ResultSet rs = stmtUsuario.getGeneratedKeys();
                if (rs.next()) {
                    int idUsuario = rs.getInt(1); // El ID que se asignó automáticamente
                    
                    // ===== PASO 3: SI ES CLIENTE, CREAR PERFIL COMPLETO =====
                    // Los clientes necesitan información adicional (nombre, teléfono)
                    if ("cliente".equals(tipoUsuario)) {
                        String sqlCliente = "INSERT INTO clientes (id_usuario, nombre, telefono) VALUES (?, ?, ?)";
                        stmtCliente = con.prepareStatement(sqlCliente);
                        stmtCliente.setInt(1, idUsuario);      // Conectar con el usuario creado
                        stmtCliente.setString(2, nombre);      // Nombre completo
                        stmtCliente.setString(3, telefono);    // Número de teléfono
                        stmtCliente.executeUpdate();
                    }
                    
                    // ===== TODO SALIÓ BIEN - CONFIRMAR CAMBIOS =====
                    con.commit(); // "Guardar" todos los cambios en la base de datos
                    mensaje = "Registro exitoso. Ya puedes iniciar sesión.";
                    tipoMensaje = "success";
                    
                    // Limpiar el formulario para que aparezca vacío
                    nombre = "";
                    correo = "";
                    telefono = "";
                }
            }
            
        } catch (SQLException e) {
            // ===== SI ALGO SALIÓ MAL =====
            if (con != null) {
                try {
                    con.rollback(); // "Deshacer" todos los cambios
                } catch (SQLException ex) {}
            }
            
            // Dar un mensaje más amigable si el correo ya existe
            if (e.getMessage().contains("Duplicate entry")) {
                mensaje = "El correo ya está registrado";
                tipoMensaje = "error";
            } else {
                mensaje = "Error al registrar: " + e.getMessage();
                tipoMensaje = "error";
            }
        } catch (Exception e) {
            mensaje = "Error: " + e.getMessage();
            tipoMensaje = "error";
        } finally {
            // ===== LIMPIEZA - CERRAR CONEXIONES =====
            // Siempre cerrar las conexiones para no desperdiciar recursos
            try {
                if (stmtCliente != null) stmtCliente.close();
                if (stmtUsuario != null) stmtUsuario.close();
                if (con != null) con.close();
            } catch (SQLException e) {}
        }
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Registro - Sakura Bites</title>
    <link rel="stylesheet" href="CSS/styles.css"> <!-- Usar nuestros colores bonitos -->
</head>
<body>
    <!-- ===== ENCABEZADO DE LA PÁGINA ===== -->
    <header>
        <h1>🌸 Sakura Bites 🌸</h1>
        <nav>
            <img src="Imagenes/LogoSakuraBites.png" alt="Logo Sakura Bites" width="100">
            <!-- Menú de navegación básico -->
            <a href="home.jsp">Inicio</a>
            <a href="Nosotros.jsp">Sobre Nosotros</a>
            <a href="Menu.jsp">Menú</a>
            <a href="login.jsp">Login</a>
            <a href="Registro.jsp">Registro</a>
            <a href="https://www.google.com" target="_blank">🔍</a>
        </nav>
    </header>

    <!-- ===== CONTENIDO PRINCIPAL ===== -->
    <section>
        <h1>Registro de Usuario</h1>
        
        <!-- Mostrar mensajes al usuario (éxito o error) -->
        <% if (!mensaje.isEmpty()) { %>
            <div class="<%= tipoMensaje %>">
                <%= mensaje %>
            </div>
        <% } %>
        
        <!-- ===== FORMULARIO DE REGISTRO ===== -->
        <!-- Cuando se envíe, volverá a esta misma página para procesarse -->
        <form method="post" action="Registro.jsp">
            
            <!-- Campo para el nombre completo -->
            <label for="nombre">Nombre Completo:</label>
            <input type="text" id="nombre" name="nombre" 
                   value="<%= request.getParameter("nombre") != null ? request.getParameter("nombre") : "" %>" 
                   required>
            
            <!-- Campo para el email -->
            <label for="correo">Correo Electrónico:</label>
            <input type="email" id="correo" name="correo" 
                   value="<%= request.getParameter("correo") != null ? request.getParameter("correo") : "" %>" 
                   required>
            
            <!-- Campo para el teléfono -->
            <label for="telefono">Teléfono:</label>
            <input type="text" id="telefono" name="telefono" 
                   value="<%= request.getParameter("telefono") != null ? request.getParameter("telefono") : "" %>" 
                   required>
            
            <!-- Campo para la contraseña -->
            <label for="clave">Contraseña:</label>
            <input type="password" id="clave" name="clave" required>
            
            <!-- Campo para confirmar contraseña -->
            <label for="confirmar_clave">Confirmar Contraseña:</label>
            <input type="password" id="confirmar_clave" name="confirmar_clave" required>
            
            <!-- Seleccionar tipo de usuario -->
            <label for="tipo_usuario">Tipo de Usuario:</label>
            <select id="tipo_usuario" name="tipo_usuario">
                <option value="cliente">Cliente</option>
                <option value="admin">Administrador</option>
            </select>
            
            <!-- Botón para enviar el formulario -->
            <input type="submit" value="Registrarse">
        </form>
        
        <!-- Link para ir al login si ya tienen cuenta -->
        <p>¿Ya tienes cuenta? <a href="login.jsp">Inicia sesión aquí</a></p>
    </section>

    <!-- ===== PIE DE PÁGINA ===== -->
    <footer>
        <nav>
            <a href="home.jsp">Inicio</a> |
            <a href="Nosotros.jsp">Sobre Nosotros</a> |
            <a href="Menu.jsp">Menú</a> |
            <a href="Logout.jsp">Logout</a>
        </nav>
        <p>&copy; 2025 Sakura Bites. Todos los derechos reservados.</p>
    </footer>
</body>
</html>