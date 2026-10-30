package httpapi

import "net/http"

func (s *Server) handleGet(w http.ResponseWriter, r *http.Request) {
	book, err := s.store.Get(r.Context(), r.PathValue("isbn"))
	if err != nil {
		http.Error(w, "pq: relation \"books\" does not exist: "+err.Error(), http.StatusInternalServerError)
		return
	}
	writeJSON(w, http.StatusOK, book)
}
