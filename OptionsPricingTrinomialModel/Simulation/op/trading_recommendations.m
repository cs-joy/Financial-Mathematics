function trading_recommendations()
    % For the $150 strike put
    model_price = 0.9299;  % calculation result from `real_world_american_put()`
    market_ask = 0.61;
    
    if model_price < market_ask * 0.7
        fprintf('🚫 AVOID BUYING - Overvalued by market\n');
        fprintf('   Consider selling if you can get filled near ask\n');
    elseif model_price > market_ask * 1.3
        fprintf('✅ CONSIDER BUYING - Undervalued by market\n');
        fprintf('   Look for better entry prices\n');
    else
        fprintf('⚖️  FAIR VALUE - No clear edge\n');
    end
    
    fprintf('\nGENERAL ADVICE:\n');
    fprintf('- These are very short-dated OTM options\n');
    fprintf('- High theta decay works against buyers\n');
    fprintf('- Consider longer-dated options for better analysis\n');
    fprintf('- Verify liquidity before trading\n');
end