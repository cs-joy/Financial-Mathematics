package com.bsc.thesis;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;

import static com.bsc.thesis.Options.vanilla.AmericanPut.americanPut;
import static com.bsc.thesis.Options.vanilla.AmericanPut.createStockTree;


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
        check();
    }

    public static void check() {
        double S0 = 100.0;
        double K = 100.0;
        double r = 0.05;
        int N = 100;
        double p = 0.4;
        double T = 1.0;
        double sigma = 0.2;

        double h = T / N;
        double u = sigma * Math.sqrt(h / (2 * p));

        double[][] stockTree = createStockTree(S0, N, u);
        double[][] optionPrices = americanPut(stockTree, K, r, N, p, h, u);

        System.out.printf("American Put Option Price: %.4f%n", optionPrices[N][0]);
    }
}