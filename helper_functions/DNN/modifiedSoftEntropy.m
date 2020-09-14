classdef modifiedSoftEntropy < nnet.layer.ClassificationLayer
               
    properties
        % Joint cost matrix
        joint_cost_main = [];
        joint_cost_dummy = [];
        N_true_class = 0;
        N_dummy_class = 0;
    end

    methods
        function layer = modifiedSoftEntropy(name, joint_cost_main, joint_cost_dummy)
            % layer = modifiedSoftEntropy(classWeights) creates a
            % weighted softmax with cross entropy loss layer. 
            % 
            % layer = modifiedSoftEntropy(classWeights, name)
            % additionally specifies the layer name. 

            % Set layer name
            if nargin == 2
                layer.Name = name;
            end
            
            layer.joint_cost_main = joint_cost_main;   
            
            layer.N_true_class = size(joint_cost_main, 2);         
            
            layer.joint_cost_dummy = joint_cost_dummy;
            
            layer.N_dummy_class = size(joint_cost_dummy, 2);

            % Set layer description
            layer.Description = 'Weighted softmax with cross entropy';
        end
        
        function loss = forwardLoss(layer, Y, T)
            % loss = forwardLoss(layer, Y, T) returns the weighted cross
            % entropy loss between the predictions Y and the training
            % targets T.
            
            N = size(Y,4);
            Y = squeeze(Y);
            T = squeeze(T);
            
            %load joint cost
            J = layer.joint_cost_main; %discritization classes
            J_dummy = layer.joint_cost_dummy; %additional points from the mech
            
            modified_T = T; %This T maps back from the original T with the 
            %dummy classes to restictring correct labels to true classes
            
            my_softmax = zeros(size(Y));         
            
            for i=1:N
                %iterate through each point in the batch (for calculation
                %simplicity)
                Y_N = reshape(Y(1:layer.N_true_class,i), [], 1); %take only nodes related to true classes
                T_N = reshape(T(:,i), [], 1);
                
                %correct label index
                index = find(T_N == 1);
                                
                if (index <= layer.N_true_class)
                    %the current target is one of the discritization points
                    
                    %get target joint cost
                    J_k = J(:, index);
                                
                else
                    %the current target is one of the dummy points
                    
                    dummy_index = index - layer.N_true_class;
                    
                    %get target joint cost
                    J_k = J_dummy(:, dummy_index);
                    
                    %remap correct labels to true classes
                    modified_T(index, i) = 0;
                    true_index = find(J_k == min(J_k(:)));
                    true_index = true_index(1); %in case multiple classes yield similar deterioration
                    modified_T(true_index, i) = 1;
                end
                
                %calculate stable softmax
                Y_scaled = J_k .* Y_N;
                exponents = Y_scaled - max(Y_scaled);
                expJY = exp(exponents);
                softmax_N = expJY/sum(expJY);
                my_softmax(1:layer.N_true_class,i) = softmax_N;
                 
            end
            
            loss_matrix = modified_T.*log(nnet.internal.cnn.util.boundAwayFromZero(my_softmax));
            loss = -sum(loss_matrix(:))/N;
        end
        
        
        function dLdY = backwardLoss(layer, Y, T)
            % dLdY = backwardLoss(layer, Y, T) returns the derivatives of
            % the weighted softmax cross entropy loss with respect to the
            % predictions Y.

            [~,~,K,N] = size(Y);
            Y = squeeze(Y);
            T = squeeze(T);
            
            %load joint cost
            J = layer.joint_cost_main; %discritization classes
            J_dummy = layer.joint_cost_dummy; %additional points from the mech
            
            %no need to calculate
            %modified_T = T; %This T maps back from the original T with
            %%dummy classes to restictring correct labels to true classes
            
            %my_softmax = zeros(size(Y)); %no need to use 
            
            dLdY  = zeros(size(Y)); 
            
            for i=1:N
                
                %iterate through each point in the batch (for calculation
                %simplicity)
                Y_N = reshape(Y(1:layer.N_true_class,i), [], 1); %take only nodes related to true classes
                T_N = reshape(T(:,i), [], 1);
                modified_T_N = T_N;
                
                %correct label index
                index = find(T_N == 1);
                                
                if (index <= layer.N_true_class)
                    %the current target is one of the discritization points
                    
                    %get target joint cost
                    J_k = J(:, index);
                                
                else
                    %the current target is one of the dummy points
                    dummy_index = index - layer.N_true_class;                    
                                     
                    %get target joint cost
                    J_k = J_dummy(:, dummy_index);                    
                    
                    %remap correct labels to true classes
                    %modified_T(index, i) = 0; %no need to calculate 
                    modified_T_N(index) = 0;
                    true_index = find(J_k == min(J_k(:)));
                    true_index = true_index(1); %in case multiple classes yield similar deterioration
                    %modified_T(true_index, i) = 1;    
                    modified_T_N(true_index) = 1;
                    
                end
                
                %calculate stable softmax
                Y_scaled = J_k .* Y_N;
                exponents = Y_scaled - max(Y_scaled);
                expJY = exp(exponents);
                softmax_N = expJY/sum(expJY);
                %my_softmax(1:layer.N_true_class,i) = softmax_N;   %no need to calculate       
                
                %dLdY(1:layer.N_true_class,i) = J_k .* (softmax_N - modified_T_N); 
                dLdY(1:layer.N_true_class,i) = J_k .* (softmax_N - modified_T_N);
            end
            
            %no need to calculate
            %dLdY = my_softmax - T;
            
            dLdY = single(dLdY);
            dLdY = reshape(dLdY,[1 1 K N]);
        end
    end
end