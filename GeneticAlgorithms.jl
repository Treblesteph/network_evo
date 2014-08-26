
module GeneticAlgorithms

# -------

importall Base

export  Entity,
        GAmodel,

        runga,
        freeze,
        defrost,
        generation_num,
        population

# -------

abstract Entity

isless(lhs::Entity, rhs::Entity) = lhs.fitness > rhs.fitness

fitness!(ent, fitness_score) = ent.fitness = fitness_score

# -------

type EntityData
    entity
    generation::Int

    EntityData(entity, generation::Int) = new(entity, generation)
    EntityData(entity, model) = new(entity, model.gen_num)
end

# -------

type GAmodel
    initial_pop_size::Int
    gen_num::Int

    population::Array
    pop_data::Array{EntityData}
    freezer::Array{EntityData}

    rng::AbstractRNG

    ga

    GAmodel() = new(0, 1, Any[], EntityData[], EntityData[], MersenneTwister(time_ns()), nothing)
end

global _g_model

# -------

function freeze(model::GAmodel, entity::EntityData)
    push!(model.freezer, entity)
    println("Freezing: ", entity)
end

function freeze(model::GAmodel, entity)
    entitydata = EntityData(entity, model.gen_num)
    freeze(model, entitydata)
end

freeze(entity) = freeze(_g_model, entity)


function defrost(model::GAmodel, generation::Int)
    filter(model.freezer) do entitydata
        entitydata.generation == generation
    end
end

defrost(generation::Int) = defrost(_g_model, generation)


generation_num(model::GAmodel = _g_model) = model.gen_num


population(model::GAmodel = _g_model) = model.population


function runga(mdl::Module; initial_pop_size = 128, stop_after = nothing)
    model = GAmodel()
    model.ga = mdl
    model.initial_pop_size = initial_pop_size

    runga(model, stop_after)
end

function runga(model::GAmodel, stop_after = nothing)
    reset_model(model)
    create_initial_population(model)
    counter = 1
    while true
        print("generation $(model.gen_num). ")
        evaluate_population(model)

        grouper = @task model.ga.group_entities(model.population)
        groupings = Any[]
        while !istaskdone(grouper)
            group = consume(grouper)
            group != nothing && push!(groupings, group)
        end

        if length(groupings) < 1
            break
        end

        crossover_population(model, groupings)
        mutate_population(model)
        println("")
        if stop_after == counter; break; end
        counter += 1
    end

    model
end

# -------

function reset_model(model::GAmodel)
    global _g_model = model

    model.gen_num = 1
    empty!(model.population)
    empty!(model.pop_data)
    empty!(model.freezer)
end

function create_initial_population(model::GAmodel)
    for i = 1:model.initial_pop_size
        entity = model.ga.create_entity(i)

        push!(model.population, entity)
        push!(model.pop_data, EntityData(entity, model.gen_num))
    end
end

function evaluate_population(model::GAmodel)
    scores = pmap(model.ga.fitness, model.population)
    print(" fitness: ")
    for i in 1:length(scores)
        fitness!(model.population[i], scores[i])
    end
    print("mean fitness: $(round(mean(scores), 4)). ")
    sort!(model.population; rev = true)
    print("Highest fitnesses: $([e.fitness for e in model.population[1:5]])")
end

function crossover_population(model::GAmodel, groupings)
    old_pop = model.population

    model.population = groupings[1]
    groupings = groupings[2:end]
    sizehint(model.population, length(old_pop))

    model.pop_data = EntityData[]
    sizehint(model.pop_data, length(old_pop))

    model.gen_num += 1
    for group in groupings
        parents = { old_pop[i] for i in group }
        entity = model.ga.crossover(parents)

        push!(model.population, entity)
        push!(model.pop_data, EntityData(model.ga.crossover(parents), model.gen_num))
    end
end

function mutate_population(model::GAmodel)
    for entity in model.population
        model.ga.mutate(entity)
    end
end

end