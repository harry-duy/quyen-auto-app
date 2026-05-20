package com.quyenauto.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Loads key=value pairs from .env (project root or working dir) into the
 * Spring environment before any other config is processed.
 * Values already set via real env vars take precedence — this only fills gaps.
 */
public class DotEnvPostProcessor implements EnvironmentPostProcessor {

    private static final String SOURCE_NAME = "dotEnvFile";

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment env,
                                       SpringApplication application) {
        Path dotEnv = resolveEnvFile();
        if (dotEnv == null) return;

        Map<String, Object> props = new LinkedHashMap<>();
        try {
            for (String line : Files.readAllLines(dotEnv)) {
                String trimmed = line.strip();
                if (trimmed.isEmpty() || trimmed.startsWith("#")) continue;
                int eq = trimmed.indexOf('=');
                if (eq <= 0) continue;
                String key   = trimmed.substring(0, eq).strip();
                String value = trimmed.substring(eq + 1).strip();
                // Only set if not already provided by a real env var or system prop
                if (!env.containsProperty(key)) {
                    props.put(key, value);
                }
            }
        } catch (IOException e) {
            // .env unreadable — silently skip; Spring will use defaults
            return;
        }

        if (!props.isEmpty()) {
            env.getPropertySources().addLast(new MapPropertySource(SOURCE_NAME, props));
        }
    }

    private Path resolveEnvFile() {
        // Check working directory first (mvnw run from backend/)
        Path candidate = Paths.get(System.getProperty("user.dir"), ".env");
        if (Files.isReadable(candidate)) return candidate;
        // Then check one level up (e.g. if run from project root)
        candidate = Paths.get(System.getProperty("user.dir"), "backend", ".env");
        if (Files.isReadable(candidate)) return candidate;
        return null;
    }
}
