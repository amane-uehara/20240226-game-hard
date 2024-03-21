module tb_Adder;

    // テストベンチ用のシグナル
    logic [7:0] a, b;
    logic [7:0] sum_expected, sum_actual;

    // Adder モジュールのインスタンス化
    Adder #(8) dut (
        .a(a),
        .b(b),
        .sum(sum_actual)
    );

    // check_function 関数の定義
    function void check_function(input logic [7:0] in_a, input logic [7:0] in_b, input logic [7:0] expected);
        // テストケースの実行
        begin
            // 入力値の設定
            a = in_a;
            b = in_b;
            sum_expected = expected;

            // シミュレーション時間の経過
            #10; // 10ns 待機

            // 結果のチェック
            check_sum($sformatf("Test Case: %d + %d", in_a, in_b), expected, sum_actual);
        end
    endfunction

    // 結果のチェック
    task check_sum(string name, logic [7:0] expected, logic [7:0] actual);
        if (expected !== actual) begin
            $display("%s: FAILED - Expected %d, Got %d", name, expected, actual);
        end else begin
            $display("%s: PASSED", name);
        end
    endtask

    // テストケースの実行
    initial begin
        check_function(5, 3, 8);
        check_function(255, 1, 0);
        $finish; // シミュレーションの終了
    end

endmodule
