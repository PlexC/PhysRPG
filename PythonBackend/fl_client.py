# fl_client.py
import flwr as fl
import torch

# Load your PyTorch model here
# model = MyVideoActionNet() 

class VideoGradingClient(fl.client.NumPyClient):
    def get_parameters(self, config):
        # Extract weights to send to the central FL server
        return [val.cpu().numpy() for _, val in model.state_dict().items()]

    def fit(self, parameters, config):
        # The server sent updated weights; train on local player data
        # set_parameters(model, parameters)
        # train(model, local_training_data, epochs=1)
        return self.get_parameters(config), len(local_training_data), {}

    def evaluate(self, parameters, config):
        # Evaluate local accuracy
        # set_parameters(model, parameters)
        # loss, accuracy = test(model, local_test_data)
        return float(loss), len(local_test_data), {"accuracy": float(accuracy)}

# Connect to the local Flower server
fl.client.start_client(server_address="127.0.0.1:8080", client=VideoGradingClient().to_client())