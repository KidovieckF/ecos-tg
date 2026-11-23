class_name SaveManager
extends RefCounted

const ARQUIVO_STATS = "user://estatisticas.json"
const ARQUIVO_RUN = "user://run_salva.json"
const ARQUIVO_HISTORICO = "user://historico_runs.json"

static var stats_globais = {
	"tempo_total_jogado": 0.0,
	"inimigos_derrotados_total": 0,
	"dano_total_causado": 0.0,
	"moedas_totais": 0,
	"runs_iniciadas": 0,
	"vitorias": 0,
	"derrotas": 0,
	"primeira_vez_lobby": true,
	"quests_concluidas": []
}

static var stats_run = {
	"tempo": 0.0,
	"inimigos_derrotados": 0,
	"dano_causado": 0.0
}

# --- REGISTRO DE EVENTOS ---

static func registrar_dano(quantidade: float) -> void:
	if quantidade <= 0: return
	stats_run["dano_causado"] += quantidade
	stats_globais["dano_total_causado"] += quantidade

static func registrar_abate() -> void:
	stats_run["inimigos_derrotados"] += 1
	stats_globais["inimigos_derrotados_total"] += 1

static func registrar_moedas(quantidade: int) -> void:
	if quantidade <= 0: return
	stats_globais["moedas_totais"] += quantidade

static func adicionar_tempo(delta: float) -> void:
	stats_run["tempo"] += delta
	stats_globais["tempo_total_jogado"] += delta

static func registrar_inicio_run() -> void:
	carregar_estatisticas()
	stats_run = {
		"tempo": 0.0,
		"inimigos_derrotados": 0,
		"dano_causado": 0.0
	}
	stats_globais["runs_iniciadas"] += 1
	salvar_estatisticas()

static func registrar_vitoria() -> void:
	stats_globais["vitorias"] += 1
	salvar_estatisticas()
	adicionar_ao_historico("Vitória")
	deletar_run_salva()

static func registrar_derrota() -> void:
	stats_globais["derrotas"] += 1
	salvar_estatisticas()
	adicionar_ao_historico("Derrota")
	deletar_run_salva()

static func eh_primeira_vez_lobby() -> bool:
	carregar_estatisticas()
	return stats_globais.get("primeira_vez_lobby", true)
	
static func marcar_lobby_como_visitado() -> void:
	stats_globais["primeira_vez_lobby"] = false
	salvar_estatisticas()
	print(">>> LOBBY: Primeira visita concluída e salva no disco.")

static func eh_quest_concluida(quest_id: String) -> bool:
	carregar_estatisticas()
	var lista = stats_globais.get("quests_concluidas", [])
	return quest_id in lista

static func concluir_quest(quest_id: String) -> void:
	carregar_estatisticas()
	if not stats_globais.has("quests_concluidas"):
		stats_globais["quests_concluidas"] = []
		
	if not quest_id in stats_globais["quests_concluidas"]:
		stats_globais["quests_concluidas"].append(quest_id)
		salvar_estatisticas()
		print("📜 Quest registrada como concluída: ", quest_id)


# --- HISTÓRICO DE RUNS ---

static func adicionar_ao_historico(resultado: String) -> void:
	var lista = obter_historico_runs()
	
	var artefatos_paths = []
	for art in RunData.artefatos_coletados:
		if art and art.resource_path != "":
			artefatos_paths.append(art.resource_path)
			
	var registro = {
		"numero": stats_globais["runs_iniciadas"],
		"seed": RunData.seed_atual,
		"resultado": resultado,
		"andar": RunData.andar,
		"tempo": formatar_tempo(stats_run["tempo"]),
		"inimigos": stats_run["inimigos_derrotados"],
		"dano": int(stats_run["dano_causado"]),
		"artefatos": artefatos_paths,
		"data": Time.get_datetime_string_from_system(false, true).substr(0, 16).replace("T", " ")
	}
	
	# Adiciona no topo para as mais recentes aparecerem primeiro
	lista.push_front(registro)
	if lista.size() > 50:
		lista.resize(50)
		
	var arquivo = FileAccess.open(ARQUIVO_HISTORICO, FileAccess.WRITE)
	if arquivo:
		arquivo.store_string(JSON.stringify(lista, "\t"))
		arquivo.close()

static func obter_historico_runs() -> Array:
	if not FileAccess.file_exists(ARQUIVO_HISTORICO):
		return []
	var arquivo = FileAccess.open(ARQUIVO_HISTORICO, FileAccess.READ)
	if not arquivo:
		return []
	var conteudo = arquivo.get_as_text()
	arquivo.close()
	var dados = JSON.parse_string(conteudo)
	if dados is Array:
		return dados
	return []

# --- SALVAR E CARREGAR ESTATÍSTICAS ---

static func salvar_estatisticas() -> void:
	var arquivo = FileAccess.open(ARQUIVO_STATS, FileAccess.WRITE)
	if arquivo:
		arquivo.store_string(JSON.stringify(stats_globais, "\t"))
		arquivo.close()

static func carregar_estatisticas() -> void:
	if not FileAccess.file_exists(ARQUIVO_STATS):
		return
	var arquivo = FileAccess.open(ARQUIVO_STATS, FileAccess.READ)
	if arquivo:
		var conteudo = arquivo.get_as_text()
		arquivo.close()
		var dados = JSON.parse_string(conteudo)
		if dados is Dictionary:
			for chave in dados.keys():
				stats_globais[chave] = dados[chave]

static func formatar_tempo(segundos_totais: float) -> String:
	var s = int(segundos_totais)
	var horas = s / 3600
	var minutos = (s % 3600) / 60
	var segs = s % 60
	if horas > 0:
		return "%02d:%02d:%02d" % [horas, minutos, segs]
	return "%02d:%02d" % [minutos, segs]

# --- SALVAR RUN NO MEIO DA PARTIDA ---

static func tem_run_salva() -> bool:
	return FileAccess.file_exists(ARQUIVO_RUN)

static func deletar_run_salva() -> void:
	if FileAccess.file_exists(ARQUIVO_RUN):
		DirAccess.remove_absolute(ARQUIVO_RUN)

static func salvar_run_atual() -> void:
	if RunData.arma_escolhida == null:
		return

	var lista_armas_dados = []
	for i in range(RunData.armas.size()):
		var arma = RunData.armas[i]
		if arma != null:
			var caminho = arma.resource_path
			if caminho == "" and i == 0 and RunData.arma_escolhida:
				caminho = RunData.arma_escolhida.resource_path
			var lista_upgrades = []
			for upg in arma.upgrades_ativos:
				if upg and upg.resource_path != "":
					lista_upgrades.append(upg.resource_path)
			lista_armas_dados.append({
				"caminho": caminho,
				"upgrades": lista_upgrades
			})

	var lista_artefatos_caminhos = []
	for art in RunData.artefatos_coletados:
		if art and art.resource_path != "":
			lista_artefatos_caminhos.append(art.resource_path)

	var arvore = Engine.get_main_loop() as SceneTree
	var cena_atual_path = arvore.current_scene.scene_file_path if arvore and arvore.current_scene else "res://Cenas/Mundo/Mundo.tscn"
	
	var player = arvore.get_first_node_in_group("Players")
	var pos_player = player.global_position if player else Vector2.ZERO
	
	var mapa_gen = null
	if arvore.current_scene:
		mapa_gen = arvore.current_scene.get_node_or_null("MapGenerator")
		if mapa_gen == null:
			mapa_gen = arvore.current_scene.get_node_or_null("MapaGen")
		if mapa_gen == null:
			for filho in arvore.current_scene.get_children():
				if "salas_criadas" in filho:
					mapa_gen = filho
					break

	var salas_limpas_coords = []
	if mapa_gen and "salas_criadas" in mapa_gen:
		for coord in mapa_gen.salas_criadas.keys():
			var s = mapa_gen.salas_criadas[coord]
			if is_instance_valid(s):
				if ("sala_limpa" in s and s.sala_limpa) or ("sensor_ja_ativado" in s and s.sensor_ja_ativado and s.contador_inimigos == 0):
					salas_limpas_coords.append({"x": coord.x, "y": coord.y})

	var dados_da_run = {
		"seed": RunData.seed_atual,
		"andar": RunData.andar,
		"cena_atual": cena_atual_path,
		"player_pos_x": pos_player.x,
		"player_pos_y": pos_player.y,
		"salas_limpas": salas_limpas_coords,
		"vida_atual": RunData.vida_atual,
		"vida_max": RunData.vida_max,
		"nivel": RunData.nivel,
		"xp_atual": RunData.xp_atual,
		"barra_exp": RunData.barra_exp,
		"dificuldade": RunData.dificuldade,
		"moeda_run": RunData.moeda_run,
		"moeda_global": RecursosGlobais.moeda,
		"personagem_path": RunData.personagem_base.resource_path if RunData.personagem_base else "",
		"arma_escolhida_path": RunData.arma_escolhida.resource_path if RunData.arma_escolhida else "",
		"armas": lista_armas_dados,
		"artefatos": lista_artefatos_caminhos,
		"stats_run": stats_run
	}

	var arquivo = FileAccess.open(ARQUIVO_RUN, FileAccess.WRITE)
	if arquivo:
		arquivo.store_string(JSON.stringify(dados_da_run, "\t"))
		arquivo.close()
		salvar_estatisticas()
		print(">>> RUN E ESTADO DO MAPA SALVOS! Salas limpas salvas: ", salas_limpas_coords.size())


static func carregar_run_salva() -> Dictionary:
	if not tem_run_salva():
		return {}

	var arquivo = FileAccess.open(ARQUIVO_RUN, FileAccess.READ)
	if not arquivo:
		return {}

	var conteudo = arquivo.get_as_text()
	arquivo.close()

	var dados = JSON.parse_string(conteudo)
	if not (dados is Dictionary):
		return {}

	RunData.resetar_run()

	RunData.seed_atual = dados.get("seed", 0)
	if RunData.seed_atual != 0:
		seed(RunData.seed_atual)

	if dados.get("personagem_path", "") != "":
		RunData.personagem_base = load(dados["personagem_path"])
	if dados.get("arma_escolhida_path", "") != "":
		RunData.arma_escolhida = load(dados["arma_escolhida_path"])
		RecursosGlobais.arma_escolhida = RunData.arma_escolhida

	RunData.andar = dados.get("andar", 1)
	RunData.dificuldade = dados.get("dificuldade", 1)
	RunData.moeda_run = dados.get("moeda_run", 0)
	RecursosGlobais.moeda = dados.get("moeda_global", 0)
	RunData.nivel = dados.get("nivel", 1)
	RunData.xp_atual = dados.get("xp_atual", 0.0)
	RunData.barra_exp = dados.get("barra_exp", 0.0)
	RunData.vida_max = dados.get("vida_max", 100.0)
	RunData.vida_atual = dados.get("vida_atual", 100.0)

	var armas_salvas = dados.get("armas", [])
	for i in range(min(armas_salvas.size(), 2)):
		var arma_info = armas_salvas[i]
		var caminho = arma_info.get("caminho", "")
		if caminho == "" and i == 0 and RunData.arma_escolhida:
			caminho = RunData.arma_escolhida.resource_path
		if caminho != "":
			var nova_arma = load(caminho).duplicate()
			nova_arma.upgrades_ativos.clear()
			for upg_path in arma_info.get("upgrades", []):
				var upg = load(upg_path)
				if upg:
					nova_arma.upgrades_ativos.append(upg)
			nova_arma.calcular_upgrades()
			RunData.armas[i] = nova_arma

	RunData.artefatos_coletados.clear()
	RunData.carregar_todos_artefatos()
	RunData.carregar_upgrades_gerais()
	for art_path in dados.get("artefatos", []):
		var art = load(art_path)
		if art:
			RunData.adicionar_artefato(art)

	RunData.vida_atual = dados.get("vida_atual", RunData.vida_max)

	if dados.has("stats_run"):
		stats_run = dados["stats_run"]

	RunData.dados_restauracao_mapa = dados

	return dados
