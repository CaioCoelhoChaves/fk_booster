# 🎯 Prompt Template 5 Estrelas

> **Como usar:** Preencha cada seção abaixo com as informações específicas da sua tarefa. Delete as dicas entre colchetes após preencher.

> 💡 **Novo!** Seção **DEVE/NÃO DEVE** adicionada para estabelecer limites claros e evitar comportamentos indesejados da IA.

---

## 1. 🌍 Contexto

[Descreva o ambiente técnico, stack, público e restrições relevantes]

**Linguagem/Framework:**
[Ex: Python 3.11 com FastAPI / Go com Gin / React com TypeScript]

**Arquitetura/Padrão:**
[Ex: Clean Architecture / Arquitetura em camadas / MVC / Microserviços]

**Público-alvo:**
[Ex: Desenvolvedores backend / Equipe de frontend / Arquitetos de software]

**Limitações/Restrições:**
[Ex: Não pode usar bibliotecas externas / Deve ser compatível com PostgreSQL 14 / Budget limitado de memória]

---

## 2. 🎯 Objetivo

[Descreva claramente o que você deseja obter da IA]

**O que precisa ser entregue:**
[Ex: Implementar feature de autenticação JWT / Criar testes unitários / Refatorar código legado]

**Propósito da tarefa:**
[Ex: Melhorar segurança / Aumentar cobertura de testes / Facilitar manutenção]

**Resultado esperado:**
[Ex: Código funcional / Documentação técnica / Plano de implementação]

---

## 3. ⚙️ Instruções Específicas

[Defina COMO a IA deve construir a resposta]

**Detalhes técnicos:**
- [Ex: Usar pgx/v5 para conexão com banco]
- [Ex: Implementar validação de entrada com tags do Gin]
- [Ex: Seguir padrão de nomenclatura do projeto]

**Restrições:**
- [Ex: NÃO usar bibliotecas ORM]
- [Ex: NÃO modificar arquivos de configuração existentes]
- [Ex: Manter compatibilidade com API v1]

**Estrutura lógica:**
- [Ex: Separar camadas: handler → service → repository]
- [Ex: Implementar tratamento de erros em cada camada]
- [Ex: Adicionar logs estruturados]

---

## 4. ✓ Regras: DEVE / NÃO DEVE

[Defina limites claros do que a IA DEVE e NÃO DEVE fazer]

### ✅ DEVE:
- [Ex: DEVE usar Context para operações de I/O]
- [Ex: DEVE seguir o padrão de nomenclatura do projeto (PascalCase/camelCase)]
- [Ex: DEVE implementar tratamento de erros com contexto usando fmt.Errorf]
- [Ex: DEVE adicionar comentários explicativos em lógicas complexas]
- [Ex: DEVE validar todos os inputs antes de processar]
- [Ex: DEVE retornar erros apropriados em cada camada]
- [Ex: DEVE escrever testes para código crítico]
- [Ex: DEVE formatar código com gofmt/prettier]

### ❌ NÃO DEVE:
- [Ex: NÃO DEVE usar bibliotecas ORM (usar apenas SQL puro)]
- [Ex: NÃO DEVE expor informações sensíveis em logs]
- [Ex: NÃO DEVE fazer breaking changes na API pública]
- [Ex: NÃO DEVE ignorar erros silenciosamente]
- [Ex: NÃO DEVE criar código duplicado (DRY - Don't Repeat Yourself)]
- [Ex: NÃO DEVE usar hardcoded values (usar variáveis de ambiente)]
- [Ex: NÃO DEVE modificar arquivos de migração já aplicados]
- [Ex: NÃO DEVE pular validações de segurança]

### ⚠️ ATENÇÃO ESPECIAL:
- [Ex: Ao manipular senhas, SEMPRE usar hashing (bcrypt)]
- [Ex: Ao fazer queries SQL, SEMPRE usar prepared statements]
- [Ex: Ao lidar com datas, SEMPRE usar UTC]

---

## 5. 📋 Formato da Resposta
[Ex: Se a resposta for longa, use subtítulos (##) e listas numeradas para facilitar leitura.]

[Especifique COMO você quer receber o resultado]

**Estrutura desejada:**
[Ex: Código completo com comentários / Plano em tópicos / Tabela comparativa / Diagrama + explicação]

**Limites:**
[Ex: Máximo 200 linhas de código / Resposta em até 3 parágrafos / Sem dependências externas]

**Estilo:**
[Ex: Responder em português / Usar markdown / Incluir exemplos de uso / Formato técnico e direto]

---

## 6. 👤 Persona / Tom

[Defina a perspectiva e forma de comunicação da IA]

**Perspectiva:**
[Ex: Desenvolvedor sênior / Arquiteto de software / Instrutor técnico / Consultor especializado]

**Tom da explicação:**
[Ex: Técnico e objetivo / Didático e detalhado / Consultivo e estratégico]

**Nível de profundidade:**
[Ex: Explicações básicas / Aprofundado com edge cases / Foco em performance / Visão de alto nível]

---

## 7. ✅ Critérios de Aceite
[Liste condições objetivas que determinam se o resultado está correto]

- [ ] [Ex: O código compila sem erros]
- [ ] [Ex: Segue o padrão de arquitetura em camadas]
- [ ] [Ex: Inclui tratamento de erros]
- [ ] [Ex: Possui testes unitários com 80%+ de cobertura]
- [ ] [Ex: Documentação atualizada]
- [ ] [Ex: Performance < 100ms por requisição]

---

## 8. 💬 Exemplos *(opcional)*

[Forneça exemplos de entrada e saída esperada se achar necessário]

**Exemplo 1:**
```
Entrada: [Descreva a entrada]
Saída esperada: [Descreva a saída]
```

**Exemplo 2:**
```
Entrada: [Descreva a entrada]
Saída esperada: [Descreva a saída]
```

---

## 💡 Dicas de Uso

* ✅ **Mínimo obrigatório:** Seções 1–6 (Contexto + Objetivo + Instruções + DEVE/NÃO DEVE + Formato + Persona)
* ⭐ **Para 6 estrelas:** Adicione seções 7–8 (Critérios de Aceite + Exemplos)
* 🎯 **Seja específico:** Quanto mais detalhes relevantes, melhor a resposta
* 🎭 **Use DEVE/NÃO DEVE:** Esta seção é crucial para evitar comportamentos indesejados
* 🔄 **Itere:** Ajuste o prompt baseado nos resultados obtidos
* 📏 **Balanceie:** Detalhes suficientes sem ser verboso demais

---
