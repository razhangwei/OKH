rbm_script_gist;
model = train_rbm(model, data);
data = add_label_data2(data, 0);
model = backprop5(model, data, 10); 
data = compute_binary_code(model, data);
measure_retrieval_perf;
visualize_neighbors;
[neighbors_out, t] = hashing3(data.label_train_code, data.label_test_code, 2);

