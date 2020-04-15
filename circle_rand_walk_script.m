%% 2D Lattice free disc random walk
clear all; close all; clc
% This script simulates a multi-layer random walk on a circle/annulus in 2 dimensions
% with radially symmetric boundary and interface conditions. The script plots the closed-form
% expressions for the moments of exit time together with stochastic estimates of the moments
% of exit time for chosen starting positions. The absorbing "exit" boundary can be chosen at 
% the outer boundary (outward configuration) or inner boundary (inward configuration).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Setup variables

% Choose to define P, the probability an agent moves in each layer or D,
% the diffusivity of each layer
%P = [0.5 0.1]; % Probability of each layer
Case = '1';
% Case = '2';
% Case = '3';
if strcmp(Case,'1')
    D = [1/60 1/6]; % Diffusivity of each layer
    R = [50 100 150]; % Radii of layers including the inner and outer boundaries
    configuration = 'outward'; % configuration
elseif strcmp(Case,'2')
    D = [1/6 1/60]; % Diffusivity of each layer
    R = [50 100 150]; % Radii of layers including the inner and outer boundaries
    configuration = 'inward'; % configuration
elseif strcmp(Case,'3')
    D = [1/60 1/6]; % Diffusivity of each layer
    R = [50 70 150]; % Radii of layers including the inner and outer boundaries
    configuration = 'outward'; % configuration
end
delta = 1; % step size per move
tau = 1; % time step
partitions = 24; % Number of sections to subdidvide step into on interface
start_radius = R(1):10:R(end); % Start radius or a vector of test radii
% start_radius = R(1); % Start radius or a vector of test radii
start_theta = 0; % Start angle (radians)
sim_num = 10000; % number of simulations to run
moments_to_plot = [1,2]; % vector of moments to create plots for 
save_plots = false; % Should plots be saved?
% Plotting uses the export_fig package (download from here: https://github.com/altmany/export_fig)
save_data = false; % Should all exit time data and parameters be saved?

% Change paths for your own computer
if save_plots
    file_path = '../../../Article write up/Figures/';
    addpath('./export_fig-master')
end

% Initialise
if exist('P','var') == 1
    D = P*delta^2/(4*tau); % Diffusivities
    if any(P>1) || any(P <= 0)
        error('Invalid probabilities defined');
    end
elseif exist('D','var') == 1
    P = 4*D*tau/(delta^2); % Probabilities
    maxD = delta^2/(4*tau);
    if any(D > maxD) 
        error(['Please choose diffusivities in the range 0 < D <= ' num2str(maxD)]);
    end
else
    error('Please define D or P')
end

% Pre-allocate arrays
exit_times_list = zeros(sim_num,length(start_radius));
raw_moment_1 = zeros(length(start_radius),1);
raw_moment_2 = zeros(length(start_radius),1);
raw_moment_3 = zeros(length(start_radius),1);
std_dev_1 = zeros(length(start_radius),1);
std_dev_2 = zeros(length(start_radius),1);
% Create strings to save data
temp_str1 = strrep(strrep(strrep(strrep(mat2str(D,3),'[',''),']',''),' ','_'),'.','p');
temp_str2 = strrep(strrep(strrep(strrep(mat2str(R),'[',''),']',''),' ','_'),'.','p');

% Check errors
if length(R) < 2 || length(R) ~= length(P)+1 || length(P) < 1
    error('Lengths of P and R are invalid')
end

if ~issorted(R) || any(R < 0)
    error('Invalid values in R');
end

if R(1) == 0 && strcmp(configuration,'inward')
    error('Exit boundary must be greater than 0');
end

if any(start_radius > R(end)) || any(start_radius < R(1))
    error('Agent must start within bounds')
end

std_dev = zeros(length(start_radius),length(moments_to_plot));
% Loop through all starting positions
parfor ii = 1:length(start_radius)
    disp(['r = ' num2str(start_radius(ii))]) % print iteration to screen
    exit_times = circle_rand_walk_func(P,R,delta,tau,partitions,...
        configuration,start_radius(ii),start_theta,sim_num);
    for jj = 1:sim_num
        exit_times_list(jj,ii) = exit_times(jj); 
    end
    raw_moment_1(ii) = mean(exit_times);
    raw_moment_2(ii) = sum(exit_times.^2)/sim_num;
    raw_moment_3(ii) = sum(exit_times.^3)/sim_num;
    std_dev_1(ii) = std(exit_times);
    std_dev_2(ii) = std(exit_times.^2); 
end
raw_moments = [raw_moment_1, raw_moment_2, raw_moment_3];

% Save data if desired
if save_data == true
    save(['circle_data_D_' temp_str1 '_Radii_' temp_str2 '_dir_' ...
            configuration '_simnum_' num2str(sim_num) '.mat']); 
end

%%
colors = lines(2);
for moment_choice = moments_to_plot
    % For arbitrary moments > 3
    if moment_choice > 3
        for k = 1:length(start_radius)
            raw_moments(k,moment_choice) = sum(exit_times_list(:,k).^moment_choice)/sim_num;   
        end
    end
    % Create figure
    figure;
    set(gcf,'Color','w')
    for k = 1:length(start_radius) % Plot error bars
        if moment_choice == 1
            stderr = std_dev_1(k)/sqrt(sim_num);
        elseif moment_choice == 2
            stderr = std_dev_2(k)/sqrt(sim_num);
        end
        plot([start_radius(k),start_radius(k)],raw_moments(k,moment_choice)+[-1,1]*stderr,...
            'Color',colors(1,:),'LineWidth',2);
        hold on
        plot([start_radius(k)-3,start_radius(k)+3],(raw_moments(k,moment_choice)-stderr)*ones(1,2),...
            'Color',colors(1,:),'LineWidth',2);
        plot([start_radius(k)-3,start_radius(k)+3],(raw_moments(k,moment_choice)+stderr)*ones(1,2),...
            'Color',colors(1,:),'LineWidth',2);
    end
    [y,M] = moments(R,D,configuration,2,R(1):delta:R(end),moment_choice);
    plot(R(1):delta:R(end),y,'Color',colors(2,:),'LineWidth',2)
    hold on
    plot(start_radius,raw_moments(:,moment_choice),'.','Color',colors(1,:),'MarkerSize',36)
    xlim([R(1),R(end)])
    xlabel('$r$','interpreter','latex')
    ylabel(['$M_{' int2str(moment_choice) '}(r)$'],'interpreter','latex')
    set(gca,'FontSize',24,'TickLabelInterpreter','LaTeX','Clipping','off')
    

    if save_plots
        if strcmp(Case,'1')
            if moment_choice == 1
                ymax = 8e4;
                ylim([0,ymax]) 
                text(-0.15,-0.15,'(a)','Units','Normalized','FontSize',30,'Interpreter','LaTeX')
                for jj = 2:length(R)-1
                    line([R(jj) R(jj)],[0,ymax],'LineStyle','--','Color',[0 0 0])
                end
                drawnow
                feval('export_fig',[file_path,'Figure1a_SI.pdf'],'-pdf')
            elseif moment_choice == 2
                ymax = 9e9;
                ylim([0,ymax]) 
                text(-0.15,-0.15,'(d)','Units','Normalized','FontSize',30,'Interpreter','LaTeX')
                for jj = 2:length(R)-1
                    line([R(jj) R(jj)],[0,ymax],'LineStyle','--','Color',[0 0 0])
                end
                drawnow
                feval('export_fig',[file_path,'Figure1d_SI.pdf'],'-pdf')
            end
        elseif strcmp(Case,'2')
            if moment_choice == 1
                ymax = 14e4;
                ylim([0,ymax])                         
                text(-0.15,-0.15,'(b)','Units','Normalized','FontSize',30,'Interpreter','LaTeX')
                for jj = 2:length(R)-1
                    line([R(jj) R(jj)],[0,ymax],'LineStyle','--','Color',[0 0 0])
                end                
                feval('export_fig',[file_path,'Figure1b_SI.pdf'],'-pdf')
                drawnow
            elseif moment_choice == 2
                ymax = 3e10;
                ylim([0,ymax])                 
                text(-0.15,-0.15,'(e)','Units','Normalized','FontSize',30,'Interpreter','LaTeX')
                for jj = 2:length(R)-1
                    line([R(jj) R(jj)],[0,ymax],'LineStyle','--','Color',[0 0 0])
                end                
                feval('export_fig',[file_path,'Figure1e_SI.pdf'],'-pdf')
                drawnow
            end
        elseif strcmp(Case,'3')
            if moment_choice == 1
                ymax = 3.5e4;
                ylim([0,ymax])                         
                text(-0.15,-0.15,'(c)','Units','Normalized','FontSize',30,'Interpreter','LaTeX')
                for jj = 2:length(R)-1
                    line([R(jj) R(jj)],[0,ymax],'LineStyle','--','Color',[0 0 0])
                end                
                feval('export_fig',[file_path,'Figure1c_SI.pdf'],'-pdf')
                drawnow
            elseif moment_choice == 2
                ymax = 15e8;
                ylim([0,ymax])         
                text(-0.15,-0.15,'(f)','Units','Normalized','FontSize',30,'Interpreter','LaTeX')
                for jj = 2:length(R)-1
                    line([R(jj) R(jj)],[0,ymax],'LineStyle','--','Color',[0 0 0])
                end                
                feval('export_fig',[file_path,'Figure1f_SI.pdf'],'-pdf')
                drawnow
            end
        end
    end
end

%% Homogenization
if ~strcmp(Case,'1')
    return
end

Deff = effective_diffusivity(D,R,configuration);
D = Deff*ones(size(D));
P = 4*D*tau/(delta^2); % Probabilities
maxD = delta^2/(4*tau);
if any(D > maxD)
    error(['Please choose diffusivities in the range 0 < D <= ' num2str(maxD)]);
end

if strcmp(configuration,'outward')
    start_radius_eff = R(1);
elseif strcmp(configuration,'inward')
    start_radius_eff = R(end);
end

% Stochastic simulations
disp(['r = ' num2str(start_radius_eff)]) % print iteration to screen
exit_times_eff = circle_rand_walk_func(P,R,delta,tau,partitions,...
    configuration,start_radius_eff,start_theta,sim_num);

%% Plot heterogeneous and homogenized histograms of exit time
figure;
set(gcf,'OuterPosition',[440   212   829   659*0.5],'Color','w')
colors = lines(7);
edges = 0:1.25e4:5e5;
if strcmp(configuration,'outward')
    h = histogram(exit_times_list(:,1),edges,'Visible','off');
elseif strcmp(configuration,'inward')
    h = histogram(exit_times_list(:,end),edges,'Visible','off');
end
counts = h.Values;
h_eff = histogram(exit_times_eff,edges,'Visible','off');
counts_eff = h_eff.Values;
clf;
stairs(edges(1:end-1),counts,'Color',colors(1,:),'LineWidth',3.0)
hold on
stairs(edges,[counts_eff,counts_eff(end)],'Color',colors(7,:),'LineWidth',3.0)
ylim([0,2000])
ylabel('frequency','Interpreter','LaTeX')
xlabel('$T_{n}$','Interpreter','LaTeX')
text(0.7,0.75,['$d = 2$ (disc)'],'Units','Normalized',...
    'FontSize',30,'Interpreter','LaTeX')
text(0.7,0.5,['$D_{\mathrm{eff}} = ',num2str(Deff,'%.4f'),'$'],'Units','Normalized',...
    'FontSize',30,'Interpreter','LaTeX')
text(-0.1,-0.3,'(a)','Units','Normalized','FontSize',30,'Interpreter','LaTeX')
set(gca,'FontSize',24,'TickLabelInterpreter','LaTeX')
if save_plots
    feval('export_fig',[file_path,'Figure3a.pdf'],'-pdf')
end
drawnow