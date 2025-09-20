package com.bsc.thesis;

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
        launch();
    }
/*
    public static void check() throws InterruptedException {
        double S0 = 10.0;
        double K = 10.0;
        double r = 0.01;
        int N = 200;
        double p = 0.4;
        double sigma = 0.3;

        double optionPrices = new American(K).calculateAmericanOptions(S0, N, r, p, sigma);

        System.out.printf("American Put Option Price: %.4f%n", optionPrices);
    }

 */
}