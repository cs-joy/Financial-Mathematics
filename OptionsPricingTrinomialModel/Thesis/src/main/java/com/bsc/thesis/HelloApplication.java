package com.bsc.thesis;

import com.bsc.thesis.Options.exotic.Asian;
import com.bsc.thesis.Options.vanilla.American;
import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;

import static com.bsc.thesis.Options.vanilla.American.*;


public class HelloApplication extends Application {
    @Override
    public void start(Stage stage) throws IOException {
        FXMLLoader fxmlLoader = new FXMLLoader(HelloApplication.class.getResource("Fxml/enhanced_v2.fxml"));
        Scene scene = new Scene(fxmlLoader.load(), 640, 480);
        stage.setTitle("ThalesZ Option Pricing Tools");
        stage.setScene(scene);
        stage.show();
    }

    public static void main(String[] args) {
        //launch();
        check();
    }

    public static void check() {
        // Parameters from the paper (Table 5.1)
        double S0 = 10.0;
        double K = 8.0;
        double r = 0.01;
        double T = 0.062;   // Time to maturity
        double sigma = 0.2;
        double p = 0.25;    // Probability for up/down (p_u = p_d = p)

        int N = 14;
        int parallelism = Runtime.getRuntime().availableProcessors();

        // Calculate parameters
        double h = T / N;
        double u = sigma * Math.sqrt(h);
        double q0 = 1 - 2 * p;

        double denominator = Math.exp(u) - Math.exp(-u);
        double qu = (Math.exp(r * h) - Math.exp(-u) - q0 * (1 - Math.exp(-u))) / denominator;
        double qd = (Math.exp(u) - Math.exp(r * h) - q0 * (Math.exp(u) - 1)) / denominator;

        // Verify probabilities sum to 1
        double sumProb = qu + q0 + qd;
        double tolerance = 1e-10;
        if (Math.abs(sumProb - 1.0) > tolerance) {
            throw new RuntimeException("Probabilities do not sum to 1. Sum: " + sumProb);
        }

        double[] Q = {qu, q0, qd};   // Risk-neutral probabilities
        double[] M = {u, 0, -u};     // Moves: up, same, down

        System.out.println("Calculating Asian option price...");
        System.out.println("N: " + N + ", Parallelism: " + parallelism);
        System.out.printf("Probabilities: qu=%.6f, q0=%.6f, qd=%.6f%n", qu, q0, qd);

        try {
            Asian pricer = new Asian(K, Q, M, N, parallelism);

            long startTime = System.currentTimeMillis();

            double price;
            price = pricer.calculatePrice(S0, r, T);


            long endTime = System.currentTimeMillis();

            System.out.printf("Asian Option Price: %.4f%n", price);
            System.out.printf("Calculation time: %d ms%n", (endTime - startTime));

            pricer.shutdown();

        } catch (Exception e) {
            System.err.println("Error calculating price: " + e.getMessage());
            e.printStackTrace();
        }
    }

}