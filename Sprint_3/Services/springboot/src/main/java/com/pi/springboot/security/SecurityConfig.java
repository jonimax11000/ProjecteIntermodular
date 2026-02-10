package com.pi.springboot.security;

import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import ch.qos.logback.classic.Logger;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;
import java.security.KeyFactory;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

import javax.crypto.spec.SecretKeySpec;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {

        private final ResourceLoader resourceLoader;

        public SecurityConfig(ResourceLoader resourceLoader) {
                this.resourceLoader = resourceLoader;
        }

        @Bean
        public SecurityFilterChain securityFilterChain(
                        HttpSecurity http,
                        JwtDecoder jwtDecoder,
                        AuthenticationEntryPoint authenticationEntryPoint,
                        AccessDeniedHandler accessDeniedHandler) throws Exception {

                http
                                .csrf(csrf -> csrf.disable())
                                .authorizeHttpRequests(auth -> auth
                                                .requestMatchers(HttpMethod.GET, "/**").permitAll()
                                                .anyRequest().authenticated())
                                .exceptionHandling(ex -> ex
                                                .authenticationEntryPoint(authenticationEntryPoint)
                                                .accessDeniedHandler(accessDeniedHandler))
                                .oauth2ResourceServer(oauth2 -> oauth2
                                                .jwt(jwt -> jwt.decoder(jwtDecoder)));

                return http.build();
        }

        @Bean
        public JwtDecoder jwtDecoder(
                        @Value("${spring.security.oauth2.resourceserver.jwt.public-key-location}") String publicKeyLocation)
                        throws Exception {

                Resource resource = resourceLoader.getResource(publicKeyLocation);

                if (!resource.exists()) {
                        throw new RuntimeException("Public key not found at: " + publicKeyLocation);
                }

                try (InputStream inputStream = resource.getInputStream()) {
                        String key = new String(FileCopyUtils.copyToByteArray(inputStream))
                                        .replace("-----BEGIN PUBLIC KEY-----", "")
                                        .replace("-----END PUBLIC KEY-----", "")
                                        .replaceAll("\\s+", "");
                        System.out.println("Public Key: " + key);
                        byte[] decoded = Base64.getDecoder().decode(key);
                        System.out.println("Decoded: " + decoded);
                        X509EncodedKeySpec spec = new X509EncodedKeySpec(decoded);
                        System.out.println("Spec: " + spec);
                        KeyFactory keyFactory = KeyFactory.getInstance("RSA");
                        System.out.println("KeyFactory: " + keyFactory);
                        RSAPublicKey publicKey = (RSAPublicKey) keyFactory.generatePublic(spec);
                        System.out.println("Public Key: " + publicKey);
                        return NimbusJwtDecoder.withPublicKey(publicKey).build();
                }
        }
}

// Filtro para logging
class JwtLoggingFilter extends OncePerRequestFilter {
        private static final Logger log = (Logger) LoggerFactory.getLogger(JwtLoggingFilter.class);

        @Override
        protected void doFilterInternal(HttpServletRequest request,
                        HttpServletResponse response,
                        FilterChain filterChain) throws ServletException, IOException {

                String authHeader = request.getHeader("Authorization");
                log.info("Authorization Header: {}", authHeader);

                if (authHeader != null && authHeader.startsWith("Bearer ")) {
                        String token = authHeader.substring(7);
                        log.info("Token recibido: {}", token.substring(0, Math.min(token.length(), 50)) + "...");
                }

                filterChain.doFilter(request, response);
        }
}