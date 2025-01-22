import dash

from dash import html, dcc, Input, Output
import plotly.express as px
import pandas as pd
import geopandas as gpd
import plotly.graph_objects as go

# Initialize the Dash app
app = dash.Dash(__name__)

# Load data
hiv_data = pd.read_csv("HIV_workers.csv")
kenya_shapefile = gpd.read_file("path/to/kenya_shapefile.shp")

# App layout
app.layout = html.Div([
    # Header
    html.H1("Kenya Healthcare Dashboard", 
            style={'textAlign': 'center', 'color': '#2c3e50', 'padding': '20px'}),
    
    # Sidebar
    html.Div([
        dcc.Tabs([
            dcc.Tab(label='Map View', children=[
                html.Div([
                    # Filters
                    html.Div([
                        html.H3("Filters"),
                        dcc.Dropdown(
                            id='county-filter',
                            options=[{'label': 'All', 'value': 'All'}] +
                                    [{'label': i, 'value': i} for i in hiv_data['County'].unique()],
                            value='All'
                        ),
                        dcc.Dropdown(
                            id='hiv-filter',
                            options=[{'label': 'All', 'value': 'All'}] +
                                    [{'label': str(i), 'value': i} for i in sorted(hiv_data['HIV prevalence'].unique())],
                            value='All'
                        ),
                        dcc.Dropdown(
                            id='worker-filter',
                            options=[{'label': 'All', 'value': 'All'}] +
                                    [{'label': i, 'value': i} for i in hiv_data['Type of Worker'].unique()],
                            value='All'
                        )
                    ], style={'width': '25%', 'float': 'left', 'padding': '20px'}),
                    
                    # Map
                    html.Div([
                        dcc.Graph(id='kenya-map')
                    ], style={'width': '75%', 'float': 'right'})
                ])
            ]),
            
            dcc.Tab(label='Bar Graph', children=[
                html.Div([
                    # Filters
                    html.Div([
                        html.H3("Filters"),
                        dcc.Dropdown(
                            id='county-filter-bar',
                            options=[{'label': 'All', 'value': 'All'}] +
                                    [{'label': i, 'value': i} for i in hiv_data['County'].unique()],
                            value='All'
                        ),
                        dcc.Dropdown(
                            id='hiv-filter-bar',
                            options=[{'label': 'All', 'value': 'All'}] +
                                    [{'label': str(i), 'value': i} for i in sorted(hiv_data['HIV prevalence'].unique())],
                            value='All'
                        ),
                        dcc.Dropdown(
                            id='worker-filter-bar',
                            options=[{'label': 'All', 'value': 'All'}] +
                                    [{'label': i, 'value': i} for i in hiv_data['Type of Worker'].unique()],
                            value='All'
                        )
                    ], style={'width': '25%', 'float': 'left', 'padding': '20px'}),
                    
                    # Bar Graph
                    html.Div([
                        dcc.Graph(id='bar-graph')
                    ], style={'width': '75%', 'float': 'right'})
                ])
            ]),
            
            dcc.Tab(label='About', children=[
                html.Div([
                    html.H2("About this Dashboard"),
                    html.P("This dashboard provides insights into healthcare workforce distribution and deficits across Kenya.")
                ], style={'padding': '20px'})
            ])
        ])
    ])
])

# Callback for filtering data
def filter_data(county_filter, hiv_filter, worker_filter):
    filtered_df = hiv_data.copy()
    
    if county_filter != 'All':
        filtered_df = filtered_df[filtered_df['County'] == county_filter]
    if hiv_filter != 'All':
        filtered_df = filtered_df[filtered_df['HIV prevalence'] == hiv_filter]
    if worker_filter != 'All':
        filtered_df = filtered_df[filtered_df['Type of Worker'] == worker_filter]
        
    return filtered_df

# Callback for map
@app.callback(
    Output('kenya-map', 'figure'),
    [Input('county-filter', 'value'),
     Input('hiv-filter', 'value'),
     Input('worker-filter', 'value')]
)
def update_map(county_filter, hiv_filter, worker_filter):
    filtered_df = filter_data(county_filter, hiv_filter, worker_filter)
    
    # Create choropleth map
    fig = go.Figure(data=go.Choroplethmapbox(
        geojson=kenya_shapefile.__geo_interface__,
        locations=filtered_df['County'],
        z=filtered_df['HIV prevalence'],
        colorscale='YlOrRd',
        text=filtered_df.apply(
            lambda x: f"County: {x['County']}<br>"
                     f"Population: {x['Population']}<br>"
                     f"HIV Prevalence: {x['HIV prevalence']}<br>"
                     f"Deficit Workers: {x['Deficit']}", axis=1
        ),
        hoverinfo='text'
    ))
    
    fig.update_layout(
        mapbox_style="carto-positron",
        mapbox=dict(
            center=dict(lat=-1.2921, lon=36.8219),  # Nairobi coordinates
            zoom=5
        )
    )
    
    return fig

# Callback for bar graph
@app.callback(
    Output('bar-graph', 'figure'),
    [Input('county-filter-bar', 'value'),
     Input('hiv-filter-bar', 'value'),
     Input('worker-filter-bar', 'value')]
)
def update_bar_graph(county_filter, hiv_filter, worker_filter):
    filtered_df = filter_data(county_filter, hiv_filter, worker_filter)
    
    # Aggregate data
    grouped_data = filtered_df.groupby('County').agg({
        'Deficit': 'sum',
        'Current Workers': 'sum'
    }).reset_index()
    
    # Create bar graph
    fig = px.bar(
        grouped_data,
        x='County',
        y='Deficit',
        title='Deficit vs Current Healthcare Workers',
        color='County'
    )
    
    fig.update_layout(
        xaxis_title="County",
        yaxis_title="Number of Workers",
        showlegend=False,
        xaxis={'tickangle': 45}
    )
    
    return fig

if __name__ == '__main__':
    app.run_server(debug=True)