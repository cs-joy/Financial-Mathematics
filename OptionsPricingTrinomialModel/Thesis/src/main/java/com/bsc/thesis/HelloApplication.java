package com.bsc.thesis;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;

import static com.bsc.thesis.Options.exotic.Compound.calculateCompoundOption;


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
        launch();
        //check();
    }

    public static void check() {
        // Parameters
        double S0 = 100;
        double K1 = 15;
        double K2 = 100;
        double T1 = 0.5;
        double T2 = 1.0;
        double r = 0.05;
        double sigma = 0.25;
        double p = 0.3;
        int N = 450; // 450

        boolean isCall = true;
        boolean onCall = false;

        double trinomialPrices = calculateCompoundOption(isCall, onCall, S0, K1, K2, T1, T2, r, sigma, p, N);

        System.out.printf("trinomial_prices = %.4f%n", trinomialPrices);
    }

}