package httpapi

import "net/http"

func (s *Server) handleGet(w http.ResponseWriter, r *http.Request) {
	book, err := s.store.Get(r.Context(), r.PathValue("isbn"))
	if err != nil {
		s.log.Error("get book", "err", err, "isbn", r.PathValue("isbn"))
		writeError(w, http.StatusInternalServerError, "internal_error", "request failed")
		return
	}
	writeJSON(w, http.StatusOK, book)
}
